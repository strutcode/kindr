create function title_description_tags(listings) returns text as $$
  select $1.title || ' ' || $1.description || ' ' || $1.category || ' ' || $1.subcategory || coalesce(array_to_string($1.skills_required, ' '), '')
$$ language sql immutable;