/*
  # Conditional Duration Field for Help Needed Requests

  1. Database Changes
    - Make duration_estimate nullable for all categories except help-needed
    - Add conditional constraint ensuring duration is required only for help-needed category
    - Update existing records to ensure data consistency
    - Add performance index for category-duration queries

  2. Data Migration
    - Set default duration for existing help-needed requests that have NULL duration
    - Allow NULL duration for non-help-needed categories

  3. Constraints
    - Duration is required only for help-needed category
    - Duration must be one of the valid values when present
    - Backwards compatible with existing data
*/

-- Step 1: First, handle existing data to ensure consistency
-- Set a default duration for any help-needed requests that might have NULL duration
UPDATE requests 
SET duration_estimate = '1hour' 
WHERE category = 'help-needed' AND duration_estimate IS NULL;

-- Step 2: Drop the existing check constraint on duration_estimate
ALTER TABLE requests 
DROP CONSTRAINT IF EXISTS requests_duration_estimate_check;

-- Step 3: Make duration_estimate nullable (this should work now since we handled NULL values)
ALTER TABLE requests 
ALTER COLUMN duration_estimate DROP NOT NULL;

-- Step 4: Now we can safely set duration to NULL for non-help-needed requests
UPDATE requests 
SET duration_estimate = NULL 
WHERE category != 'help-needed';

-- Step 5: Add new conditional check constraint
-- Duration is required only for "help-needed" category
ALTER TABLE requests 
ADD CONSTRAINT requests_conditional_duration_check 
CHECK (
  (category = 'help-needed' AND duration_estimate IS NOT NULL AND duration_estimate IN ('15min', '1hour', '1day', 'multiple-days'))
  OR 
  (category != 'help-needed' AND (duration_estimate IS NULL OR duration_estimate IN ('15min', '1hour', '1day', 'multiple-days')))
);

-- Step 6: Create index for better query performance on category-duration combinations
CREATE INDEX IF NOT EXISTS idx_requests_category_duration 
ON requests(category, duration_estimate) 
WHERE category = 'help-needed';

-- Step 7: Add comment for documentation
COMMENT ON CONSTRAINT requests_conditional_duration_check ON requests IS 
'Duration estimate is required only for help-needed category requests';

/*
  ROLLBACK PROCEDURE:
  
  To rollback this migration, run the following commands:
  
  -- Remove the conditional constraint
  ALTER TABLE requests DROP CONSTRAINT IF EXISTS requests_conditional_duration_check;
  
  -- Remove the index
  DROP INDEX IF EXISTS idx_requests_category_duration;
  
  -- Set default duration for all NULL values before making column NOT NULL
  UPDATE requests SET duration_estimate = '1hour' WHERE duration_estimate IS NULL;
  
  -- Make duration_estimate required again
  ALTER TABLE requests ALTER COLUMN duration_estimate SET NOT NULL;
  
  -- Restore original constraint
  ALTER TABLE requests 
  ADD CONSTRAINT requests_duration_estimate_check 
  CHECK (duration_estimate IN ('15min', '1hour', '1day', 'multiple-days'));
*/