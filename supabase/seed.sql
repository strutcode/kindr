-- Users data (20 diverse LA users)
SELECT create_seed_user('Maria Rodriguez', 'maria.rodriguez@gmail.com');
SELECT create_seed_user('James Chen', 'james.chen@yahoo.com');
SELECT create_seed_user('Sarah Johnson', 'sarah.j.johnson@outlook.com');
SELECT create_seed_user('David Kim', 'dkim2024@gmail.com');
SELECT create_seed_user('Ashley Williams', 'ashley.williams@hotmail.com');
SELECT create_seed_user('Carlos Mendoza', 'carlitos.mendoza@gmail.com');
SELECT create_seed_user('Jennifer Liu', 'jenniferliu88@yahoo.com');
SELECT create_seed_user('Michael Brown', 'mbrown.la@gmail.com');
SELECT create_seed_user('Amanda Thompson', 'amanda.thompson@outlook.com');
SELECT create_seed_user('Roberto Garcia', 'roberto.garcia.la@gmail.com');
SELECT create_seed_user('Jessica Park', 'jessica.park@yahoo.com');
SELECT create_seed_user('Daniel Martinez', 'dan.martinez@gmail.com');
SELECT create_seed_user('Emily Davis', 'emily.davis.la@hotmail.com');
SELECT create_seed_user('Alexander Nguyen', 'alex.nguyen@gmail.com');
SELECT create_seed_user('Sophia Anderson', 'sophia.anderson@outlook.com');
SELECT create_seed_user('Tyler Jackson', 'tyler.jackson.la@yahoo.com');
SELECT create_seed_user('Isabella Hernandez', 'isabella.hernandez@gmail.com');
SELECT create_seed_user('Kevin Wong', 'kevin.wong.la@gmail.com');
SELECT create_seed_user('Rachel Green', 'rachel.green.la@hotmail.com');
SELECT create_seed_user('Antonio Lopez', 'antonio.lopez@gmail.com');

-- Listings data (50 diverse community listings)

-- FREE STUFF LISTINGS (30 listings)
SELECT create_seed_listing(
  random_user_id(),
  'Free couch - good condition!',
  'Hey everyone! Moving next week and need to get rid of my couch. Its beige fabric, maybe 6 feet long, really comfortable. No stains or anything. You just need to pick it up from my apartment in Hollywood. First come first serve!',
  ST_MakePoint(-118.3267, 34.0928),
  'free-stuff',
  'furniture'
);

SELECT create_seed_listing(
  random_user_id(),
  'Baby clothes 0-6 months',
  'My little one grew out of these so fast! Have about 20 pieces - onesies, sleepers, pants. All clean and in great shape. Mix of brands like Carters and Gerber. Perfect for new parents!',
  ST_MakePoint(-118.2437, 34.0522),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Old TV that still works',
  'Got a new smart TV so dont need this 32" Samsung anymore. Its maybe 8 years old but picture is still good. Has HDMI ports. You pick up from Venice area.',
  ST_MakePoint(-118.4695, 34.0194),
  'free-stuff',
  'electronics'
);

SELECT create_seed_listing(
  random_user_id(),
  'Bunch of books - fiction mostly',
  'Cleaned out my bookshelf. Have like 15-20 novels, mostly romance and mystery. Some Stephen King, some Nicholas Sparks. All paperback. Take some or take all idc',
  ST_MakePoint(-118.2889, 34.0224),
  'free-stuff',
  'books'
);

SELECT create_seed_listing(
  random_user_id(),
  'Kitchen stuff - pots, pans, utensils',
  'Moving in with my boyfriend and we have duplicate everything. Good quality stuff from Target and Ikea. 2 pots, 3 pans, bunch of utensils, some plates and bowls. All clean!',
  ST_MakePoint(-118.3896, 34.0736),
  'free-stuff',
  'household'
);

SELECT create_seed_listing(
  random_user_id(),
  'womens clothes size medium',
  'spring cleaning time! have a bunch of clothes that dont fit me anymore. mostly business casual and some casual weekend stuff. gap, banana republic, h&m. good condition.',
  ST_MakePoint(-118.2566, 34.0466),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free plants - succulents and herbs',
  'I have way too many plants and theyre taking over my balcony lol. Have some succulents that are super easy to care for, plus basil and mint. Bring your own pots or containers.',
  ST_MakePoint(-118.4912, 34.0194),
  'free-stuff',
  'plants'
);

SELECT create_seed_listing(
  random_user_id(),
  'Exercise equipment - dumbbells and mat',
  'Bought all this stuff during covid and barely used it 😅 Have 5lb, 10lb, and 15lb dumbbells plus a yoga mat. The mat is purple and barely used.',
  ST_MakePoint(-118.1445, 34.1478),
  'free-stuff',
  'sports'
);

SELECT create_seed_listing(
  random_user_id(),
  'Dog toys and accessories',
  'My dog passed away last month and I want these to go to a good home. Have some toys, a leash, food bowls, and a dog bed. Everything is clean and in good shape.',
  ST_MakePoint(-118.2851, 34.0969),
  'free-stuff',
  'pet-supplies'
);

SELECT create_seed_listing(
  random_user_id(),
  'Mens dress shirts size large',
  'Changed jobs and dont need these anymore. Have 6 dress shirts, mostly white and light blue. All from Mens Wearhouse. Couple have minor stains but still wearable.',
  ST_MakePoint(-118.3774, 34.0567),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Board games - family friendly',
  'Kids are teenagers now and dont want to play board games with mom and dad anymore 😭 Have Monopoly, Scrabble, Uno, and a few others. All complete with instructions.',
  ST_MakePoint(-118.2278, 34.0928),
  'free-stuff',
  'toys'
);

SELECT create_seed_listing(
  random_user_id(),
  'Office supplies - binders, paper, etc',
  'Just finished school and have tons of office supplies left over. Binders, notebooks, pens, highlighters, printer paper. Take whatever you need for school or work.',
  ST_MakePoint(-118.3644, 34.0394),
  'free-stuff',
  'office'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free firewood',
  'Had a tree trimmed and have a bunch of good firewood. Already cut and seasoned. Great for camping or if you have a fireplace. You haul it away.',
  ST_MakePoint(-118.2623, 34.1341),
  'free-stuff',
  'outdoor'
);

SELECT create_seed_listing(
  random_user_id(),
  'Art supplies - paints, brushes, canvas',
  'Switched from painting to photography. Have acrylic paints, brushes, small canvases, and an easel. Some stuff is used but plenty left. Perfect for beginners!',
  ST_MakePoint(-118.4637, 34.0522),
  'free-stuff',
  'art'
);

SELECT create_seed_listing(
  random_user_id(),
  'Coffee maker and mugs',
  'Got a fancy espresso machine so dont need my old Mr Coffee anymore. Works perfectly fine. Also have like 8 coffee mugs, mix of different designs.',
  ST_MakePoint(-118.2520, 34.0687),
  'free-stuff',
  'appliances'
);

SELECT create_seed_listing(
  random_user_id(),
  'Kids toys - ages 3-8',
  'My kids outgrew these. Have action figures, dolls, legos, puzzles. Everything is clean and working. Some boxes might be missing but toys are all there.',
  ST_MakePoint(-118.3311, 34.0981),
  'free-stuff',
  'toys'
);

SELECT create_seed_listing(
  random_user_id(),
  'Bedding - sheets, pillows, blankets',
  'Just redecorated and have extra bedding. Queen size sheets (blue and white), 4 pillows, and a couple throw blankets. All washed and ready to go.',
  ST_MakePoint(-118.2019, 34.0522),
  'free-stuff',
  'household'
);

SELECT create_seed_listing(
  random_user_id(),
  'Bike helmet and gear',
  'Stopped biking after an accident (nothing serious). Have a really good helmet, bike lights, and a water bottle holder. Helmet is size medium.',
  ST_MakePoint(-118.4456, 34.0598),
  'free-stuff',
  'sports'
);

SELECT create_seed_listing(
  random_user_id(),
  'Makeup and skincare products',
  'Bought way too much makeup and most of it doesnt work with my skin tone. All barely used or brand new. Have foundation, lipstick, eyeshadow, moisturizer.',
  ST_MakePoint(-118.2889, 34.0677),
  'free-stuff',
  'beauty'
);

SELECT create_seed_listing(
  random_user_id(),
  'Christmas decorations',
  'Moving to a smaller place and cant store all my Christmas stuff. Have lights, ornaments, garland, and a small artificial tree. Perfect for someone just starting out.',
  ST_MakePoint(-118.3267, 34.0736),
  'free-stuff',
  'holiday'
);

SELECT create_seed_listing(
  random_user_id(),
  'Textbooks - business and economics',
  'Graduated and dont need these anymore. Have microeconomics, macroeconomics, business law, and accounting books. Couple are older editions but still good for learning.',
  ST_MakePoint(-118.2437, 34.0736),
  'free-stuff',
  'books'
);

SELECT create_seed_listing(
  random_user_id(),
  'Garden tools and pots',
  'Moving to an apartment with no yard 😢 Have shovels, watering can, plant pots in different sizes, and some soil. Everything is in good working condition.',
  ST_MakePoint(-118.3774, 34.0394),
  'free-stuff',
  'garden'
);

SELECT create_seed_listing(
  random_user_id(),
  'Cleaning supplies',
  'Bought in bulk and have way too much. Have all purpose cleaner, glass cleaner, sponges, paper towels. All name brand stuff like Windex and Lysol.',
  ST_MakePoint(-118.2851, 34.0522),
  'free-stuff',
  'household'
);

SELECT create_seed_listing(
  random_user_id(),
  'Computer monitor - 21 inch',
  'Upgraded to a bigger monitor. This one is 21 inches, works perfectly. Has VGA and DVI connections. Good for office work or gaming. No dead pixels.',
  ST_MakePoint(-118.4912, 34.0736),
  'free-stuff',
  'electronics'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free lumber - construction leftovers',
  'Just finished a DIY project and have leftover wood. Mix of 2x4s and plywood pieces. Some are pretty long, perfect for small projects or crafts.',
  ST_MakePoint(-118.1889, 34.0928),
  'free-stuff',
  'building'
);

SELECT create_seed_listing(
  random_user_id(),
  'DVDs - movies and TV shows',
  'Everything is streaming now so dont need these anymore. Have like 50 DVDs - action movies, comedies, some TV series. All in good condition with cases.',
  ST_MakePoint(-118.3456, 34.0466),
  'free-stuff',
  'media'
);

SELECT create_seed_listing(
  random_user_id(),
  'Baby gear - stroller, high chair',
  'Kids are older now and we dont need baby stuff anymore. Have an umbrella stroller and a high chair. Both are clean and work perfectly. From smoke free home.',
  ST_MakePoint(-118.2623, 34.0394),
  'free-stuff',
  'baby'
);

SELECT create_seed_listing(
  random_user_id(),
  'Guitar accessories',
  'Sold my guitar but still have picks, strings, a strap, and a music stand. The strap is leather and in really good condition. Perfect for someone learning guitar.',
  ST_MakePoint(-118.4078, 34.0522),
  'free-stuff',
  'music'
);

SELECT create_seed_listing(
  random_user_id(),
  'Bathroom stuff - towels, shower curtain',
  'Redecorated my bathroom and have extra stuff. 4 bath towels (blue), 2 hand towels, and a shower curtain with hooks. Everything is clean and good quality.',
  ST_MakePoint(-118.2278, 34.0687),
  'free-stuff',
  'household'
);

SELECT create_seed_listing(
  random_user_id(),
  'Food storage containers',
  'Have way too many tupperware containers! Mix of sizes, all with matching lids. Great for meal prep or storing leftovers. All dishwasher safe.',
  ST_MakePoint(-118.3644, 34.0928),
  'free-stuff',
  'kitchen'
);

-- HELP NEEDED LISTINGS (15 listings)
SELECT create_seed_listing(
  random_user_id(),
  'need someone to drive me home from surgery',
  'having minor surgery next tuesday and need someone to pick me up and drive me home. should only take like 30 minutes. surgery center is in beverly hills and i live in hollywood. can pay gas money',
  ST_MakePoint(-118.3267, 34.0928),
  'help-needed',
  'transportation',
  '30-min',
  NULL,
  'gas money'
);

SELECT create_seed_listing(
  random_user_id(),
  'Help moving a couch up stairs',
  'Just bought a couch and need help getting it up to my 2nd floor apartment. The delivery guys wont take it up stairs. Should only take 15-20 minutes max. I can offer pizza and drinks!',
  ST_MakePoint(-118.2437, 34.0522),
  'help-needed',
  'moving',
  '30-min',
  '{"heavy lifting"}',
  'pizza and drinks'
);

SELECT create_seed_listing(
  random_user_id(),
  'my kitchen faucet is leaking bad',
  'water is dripping constantly and i dont know how to fix it. seems like it might be a simple repair but im not handy at all. can pay for parts and labor if reasonable',
  ST_MakePoint(-118.2889, 34.0224),
  'help-needed',
  'repair',
  '1-hour',
  '{"plumbing", "tools"}',
  'parts and reasonable labor'
);

SELECT create_seed_listing(
  random_user_id(),
  'Need help hanging pictures on wall',
  'Just moved in and have like 8 pictures to hang but dont have a drill or level. Should be pretty quick if you have the right tools. Happy to provide lunch!',
  ST_MakePoint(-118.3896, 34.0736),
  'help-needed',
  'household',
  '1-hour',
  '{"drill", "level"}',
  'lunch'
);

SELECT create_seed_listing(
  random_user_id(),
  'can someone help me jump my car?',
  'battery is dead and im stuck in a parking lot in santa monica. have jumper cables but need someone with a working car. should only take 5 minutes once you get here',
  ST_MakePoint(-118.4912, 34.0194),
  'help-needed',
  'automotive',
  '15-min',
  '{"car", "jumper cables"}'
);

SELECT create_seed_listing(
  random_user_id(),
  'Help setting up my new TV',
  'Got a 55 inch TV and have no idea how to connect all the cables and set it up. Its still in the box. Would really appreciate someone who knows about electronics to help me out.',
  ST_MakePoint(-118.1445, 34.1478),
  'help-needed',
  'tech',
  '1-hour',
  '{"electronics knowledge"}'
);

SELECT create_seed_listing(
  random_user_id(),
  'need extra hands to move some boxes',
  'packing up my apartment and have about 10 heavy boxes that need to go from 3rd floor to moving truck. just need someone with a strong back for maybe 20 minutes. can pay $20 cash',
  ST_MakePoint(-118.2851, 34.0969),
  'help-needed',
  'moving',
  '30-min',
  '{"heavy lifting"}',
  '$20 cash'
);

SELECT create_seed_listing(
  random_user_id(),
  'Computer wont turn on - need tech help',
  'My laptop just died and I have important work files on it. Need someone who knows about computers to take a look. Might be something simple but Im not tech savvy at all.',
  ST_MakePoint(-118.3774, 34.0567),
  'help-needed',
  'tech',
  '2-hours',
  '{"computer repair"}'
);

SELECT create_seed_listing(
  random_user_id(),
  'help with grocery shopping',
  'broke my leg and cant drive or walk around store easily. need someone to pick up groceries for me. i can pay you back plus extra for your time. have a list ready',
  ST_MakePoint(-118.2278, 34.0928),
  'help-needed',
  'errands',
  '1-hour',
  '{"car", "shopping"}',
  'groceries cost plus $15'
);

SELECT create_seed_listing(
  random_user_id(),
  'Toilet is clogged really bad',
  'tried everything i can think of but toilet is still clogged. plumber wants $200 just to come look at it. maybe someone with plumbing experience can help? willing to pay fair price',
  ST_MakePoint(-118.3644, 34.0394),
  'help-needed',
  'repair',
  '30-min',
  '{"plumbing tools"}',
  'fair payment'
);

SELECT create_seed_listing(
  random_user_id(),
  'need help assembling ikea furniture',
  'bought a dresser and bookshelf from ikea and the instructions might as well be in hieroglyphics. need someone patient who has done this before. can provide snacks and drinks',
  ST_MakePoint(-118.2623, 34.1341),
  'help-needed',
  'assembly',
  '2-hours',
  '{"tools", "patience"}',
  'snacks and drinks'
);

SELECT create_seed_listing(
  random_user_id(),
  'Help with yard work',
  'Have a small yard that needs weeding and some basic cleanup. Nothing too heavy duty but I just dont have time to do it myself. Can pay $15/hour cash.',
  ST_MakePoint(-118.4637, 34.0522),
  'help-needed',
  'yard-work',
  '4-hours',
  '{"gardening tools"}',
  '$15/hour cash'
);

SELECT create_seed_listing(
  random_user_id(),
  'someone to watch my dog for a few hours',
  'have a vet appointment that might take a while and cant bring my dog. hes super friendly and just needs someone to hang out with him at my place for like 3-4 hours',
  ST_MakePoint(-118.2520, 34.0687),
  'help-needed',
  'pet-care',
  '4-hours',
  '{"comfortable with dogs"}'
);

SELECT create_seed_listing(
  random_user_id(),
  'Need help loading a truck',
  'Rented a U-Haul and need help loading furniture and boxes. Everything is already packed, just need strong people to help carry stuff. Should take about 2 hours max.',
  ST_MakePoint(-118.3311, 34.0981),
  'help-needed',
  'moving',
  '2-hours',
  '{"heavy lifting"}',
  '$40 total'
);

SELECT create_seed_listing(
  random_user_id(),
  'help me understand my phone bill',
  'got a crazy high phone bill and dont understand all the charges. need someone who knows about cell phone plans to help me figure out whats going on. senior citizen here!',
  ST_MakePoint(-118.2019, 34.0522),
  'help-needed',
  'tech',
  '30-min',
  '{"cell phone knowledge"}'
);

-- SKILLS OFFERED LISTINGS (5 listings)
SELECT create_seed_listing(
  random_user_id(),
  'I can help with basic home repairs',
  'Been doing handyman work for years and have some free time on weekends. Good with fixing leaky faucets, replacing light fixtures, basic electrical stuff. Just want to help neighbors out.',
  ST_MakePoint(-118.4456, 34.0598),
  'skills-offered',
  'repair'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free tutoring in spanish',
  'Native speaker and former teacher. Happy to help anyone learning Spanish - kids or adults. Can meet at library or coffee shop. Just love helping people learn languages!',
  ST_MakePoint(-118.2889, 34.0677),
  'skills-offered',
  'tutoring'
);

SELECT create_seed_listing(
  random_user_id(),
  'woodworking help - need practice!',
  'learning woodworking and need projects to practice on. if you need simple shelves, small repairs, or basic furniture built i can help for free. just cover materials',
  ST_MakePoint(-118.3267, 34.0736),
  'skills-offered',
  'woodworking'
);

SELECT create_seed_listing(
  random_user_id(),
  'Can help with computer problems',
  'Work in IT and happy to help with basic computer issues in my spare time. Virus removal, software installation, teaching basic computer skills. No charge, just want to help community.',
  ST_MakePoint(-118.2437, 34.0736),
  'skills-offered',
  'tech'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free dog walking for seniors',
  'Love dogs and want to help senior citizens who might have trouble walking their pets. Available most afternoons and weekends. Have experience with dogs of all sizes.',
  ST_MakePoint(-118.3774, 34.0394),
  'skills-offered',
  'pet-care'
);
