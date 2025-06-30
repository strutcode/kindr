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
  ST_MakePoint(-118.3089, 34.0736),
  'free-stuff',
  'plants'
);

SELECT create_seed_listing(
  random_user_id(),
  'Exercise equipment - dumbbells and mat',
  'Bought all this stuff during covid and barely used it 😅 Have 5lb, 10lb, and 15lb dumbbells plus a yoga mat. The mat is purple and barely used.',
  ST_MakePoint(-118.1445, 34.1478),
  'free-stuff',
  'fitness'
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
  'fitness'
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
  'outdoor'
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
  ST_MakePoint(-118.2851, 34.0466),
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
  'need ride home from medical procedure',
  'having a minor procedure done thursday morning and need someone to give me a ride home afterwards. doctor says i cant drive for rest of the day. live in burbank, procedure is in glendale. happy to pay for gas',
  ST_MakePoint(-118.3089, 34.1808),
  'help-needed',
  'transportation',
  '45-min',
  NULL,
  'gas money'
);

SELECT create_seed_listing(
  random_user_id(),
  'Help getting heavy dresser upstairs',
  'Bought a dresser from facebook marketplace and need help carrying it up to my 3rd floor apartment. Its solid wood and really heavy. Should take about 30 minutes. Can buy you lunch afterwards!',
  ST_MakePoint(-118.0808, 34.0761),
  'help-needed',
  'moving',
  '30-min',
  '{"heavy lifting"}',
  'lunch'
);

SELECT create_seed_listing(
  random_user_id(),
  'bathroom sink wont drain properly',
  'sink has been draining super slow for weeks and now its completely backed up. tried draino but didnt work. need someone who knows plumbing to take a look. can pay reasonable rate',
  ST_MakePoint(-118.4011, 34.2367),
  'help-needed',
  'repair',
  '1-hour',
  '{"plumbing knowledge"}',
  'reasonable payment for repair'
);

SELECT create_seed_listing(
  random_user_id(),
  'Need help mounting TV on wall',
  'Got a wall mount for my TV but have no idea how to install it safely. Dont want it falling down! Need someone with tools and experience. Will provide dinner and drinks.',
  ST_MakePoint(-118.2370, 34.1843),
  'help-needed',
  'installation',
  '1-hour',
  '{"drill", "stud finder", "mounting experience"}',
  'dinner and drinks'
);

SELECT create_seed_listing(
  random_user_id(),
  'car battery died at work',
  'my car wont start and im stuck in the parking lot at my office in downtown LA. think the battery is dead. have cables but need someone to jump it. can venmo you for gas',
  ST_MakePoint(-118.2437, 34.0522),
  'help-needed',
  'automotive',
  '15-min',
  '{"car with good battery"}',
  'venmo for gas'
);

SELECT create_seed_listing(
  random_user_id(),
  'Help connecting new router and wifi',
  'Internet company installed new router but now nothing works right. Need someone who understands networking to help get everything connected properly again.',
  ST_MakePoint(-117.9473, 34.1064),
  'help-needed',
  'tech',
  '1-hour',
  '{"networking knowledge"}'
);

SELECT create_seed_listing(
  random_user_id(),
  'moving day help - loading truck',
  'rented a moving truck and need 2-3 people to help load boxes and furniture. everything is packed and ready to go. should take about 90 minutes. paying $25 per person cash',
  ST_MakePoint(-118.2589, 34.0522),
  'help-needed',
  'moving',
  '2-hours',
  '{"heavy lifting"}',
  '$25 per person cash'
);

SELECT create_seed_listing(
  random_user_id(),
  'Laptop screen cracked - need data backup',
  'Dropped my laptop and screen is completely cracked. Cant see anything but computer still turns on. Need someone to help me backup all my photos and documents.',
  ST_MakePoint(-118.1553, 34.0633),
  'help-needed',
  'tech',
  '2-hours',
  '{"computer skills", "external drive"}'
);

SELECT create_seed_listing(
  random_user_id(),
  'need someone to pick up prescription',
  'recovering from foot surgery and cant drive. need someone to pick up my medication from CVS and bring it to me. can pay you back plus $10 for your time',
  ST_MakePoint(-118.0662, 33.9189),
  'help-needed',
  'errands',
  '30-min',
  '{"car", "ID for pickup"}',
  'medication cost plus $10'
);

SELECT create_seed_listing(
  random_user_id(),
  'Garbage disposal is jammed',
  'Something got stuck in my garbage disposal and now it wont turn on. tried the reset button but nothing. need someone who knows about these things to fix it',
  ST_MakePoint(-118.3640, 34.1808),
  'help-needed',
  'repair',
  '45-min',
  '{"tools", "disposal knowledge"}',
  'will pay for parts and labor'
);

SELECT create_seed_listing(
  random_user_id(),
  'help putting together exercise equipment',
  'bought a home gym setup and the assembly instructions are impossible to understand. need someone patient who has done this kind of thing before. have all the tools',
  ST_MakePoint(-118.0370, 34.0154),
  'help-needed',
  'assembly',
  '2-hours',
  '{"patience", "assembly experience"}',
  'pizza and beer'
);

SELECT create_seed_listing(
  random_user_id(),
  'Front yard needs cleanup',
  'Yard is overgrown with weeds and needs serious help. Too much for me to handle alone. Need someone with experience doing yard work. Can pay $20/hour.',
  ST_MakePoint(-118.2927, 34.2078),
  'help-needed',
  'yard-work',
  '2-hours',
  '{"gardening tools", "yard work experience"}',
  '$20/hour'
);

SELECT create_seed_listing(
  random_user_id(),
  'need cat sitter for weekend',
  'going out of town for the weekend and need someone to check on my two cats. just need feeding and litter box cleaning. cats are very friendly and easy going',
  ST_MakePoint(-118.3456, 34.0736),
  'help-needed',
  'pet-care',
  'multiple-days',
  '{"comfortable with cats"}',
  '$40 for the weekend'
);

SELECT create_seed_listing(
  random_user_id(),
  'Help unloading delivery truck',
  'Having furniture delivered but delivery guys wont bring it inside. Need 2 people to help unload truck and carry stuff to my apartment. Heavy lifting involved.',
  ST_MakePoint(-118.1825, 34.1931),
  'help-needed',
  'moving',
  '1-hour',
  '{"heavy lifting"}',
  '$30 total to split'
);

SELECT create_seed_listing(
  random_user_id(),
  'confused about new smartphone',
  'just got a new phone and cant figure out how to transfer my contacts and photos from my old one. need someone patient who can teach me the basics. im 68 years old',
  ST_MakePoint(-117.9445, 33.8734),
  'help-needed',
  'tech',
  '1-hour',
  '{"smartphone knowledge", "patience with seniors"}'
);

-- SKILLS OFFERED LISTINGS (5 listings)
SELECT create_seed_listing(
  random_user_id(),
  'Free help with small electrical jobs',
  'Licensed electrician with free time on weekends. Happy to help with simple jobs like installing ceiling fans, replacing outlets, fixing light switches. Just want to help the community.',
  ST_MakePoint(-118.3871, 34.2367),
  'skills-offered',
  'electrical'
);

SELECT create_seed_listing(
  random_user_id(),
  'English tutoring for non-native speakers',
  'ESL teacher with 10 years experience. Offering free English conversation practice and grammar help for adults learning English. Can meet at coffee shops or library.',
  ST_MakePoint(-118.1108, 34.1064),
  'skills-offered',
  'tutoring'
);

SELECT create_seed_listing(
  random_user_id(),
  'automotive repairs - learning mechanic',
  'studying to be a mechanic and need practice working on different cars. can help with basic maintenance like oil changes, brake pads, tune-ups. you just pay for parts',
  ST_MakePoint(-118.0370, 33.9425),
  'skills-offered',
  'automotive'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free website help for small businesses',
  'Web developer wanting to build portfolio. Can help small businesses create simple websites, fix existing sites, or teach basic web maintenance. No charge.',
  ST_MakePoint(-118.2927, 34.2078),
  'skills-offered',
  'web-design'
);

SELECT create_seed_listing(
  random_user_id(),
  'Pet grooming practice needed',
  'Learning pet grooming and need dogs to practice on. Basic bath, brush, nail trim. Your dog gets pampered for free and I get practice. Win-win!',
  ST_MakePoint(-118.4370, 34.0520),
  'skills-offered',
  'pet-grooming'
);

-- ADDITIONAL USERS (20 more diverse LA/Long Beach users)
SELECT create_seed_user('Miguel Santos', 'miguel.santos@gmail.com');
SELECT create_seed_user('Grace Kim', 'grace.kim.lb@yahoo.com');
SELECT create_seed_user('Brandon Miller', 'brandon.miller@outlook.com');
SELECT create_seed_user('Priya Patel', 'priya.patel.la@gmail.com');
SELECT create_seed_user('Jordan Washington', 'jordan.washington@hotmail.com');
SELECT create_seed_user('Elena Morales', 'elena.morales@gmail.com');
SELECT create_seed_user('Ryan O''Connor', 'ryan.oconnor.lb@yahoo.com');
SELECT create_seed_user('Fatima Al-Hassan', 'fatima.alhassan@gmail.com');
SELECT create_seed_user('Marcus Johnson', 'marcus.johnson.la@outlook.com');
SELECT create_seed_user('Carmen Ruiz', 'carmen.ruiz@gmail.com');
SELECT create_seed_user('Trevor Chang', 'trevor.chang@yahoo.com');
SELECT create_seed_user('Aaliyah Brown', 'aaliyah.brown.lb@gmail.com');
SELECT create_seed_user('Diego Flores', 'diego.flores@hotmail.com');
SELECT create_seed_user('Nina Volkov', 'nina.volkov@gmail.com');
SELECT create_seed_user('Jamal Roberts', 'jamal.roberts.la@yahoo.com');
SELECT create_seed_user('Samantha Lee', 'samantha.lee@outlook.com');
SELECT create_seed_user('Ahmed Hassan', 'ahmed.hassan@gmail.com');
SELECT create_seed_user('Chloe Davis', 'chloe.davis.lb@hotmail.com');
SELECT create_seed_user('Victor Gonzales', 'victor.gonzales@gmail.com');
SELECT create_seed_user('Zoe Mitchell', 'zoe.mitchell.la@yahoo.com');

-- ADDITIONAL LISTINGS (50 more diverse community listings)

-- UNIQUE FREE STUFF LISTINGS (30 new listings - replacing duplicates)
SELECT create_seed_listing(
  random_user_id(),
  'Free nightstand - white wood',
  'Moving to furnished apartment and dont need this anymore. White wooden nightstand with one drawer. Minor scuffs but still functional. Matches most bedroom furniture.',
  ST_MakePoint(-118.4490, 34.1869),
  'free-stuff',
  'furniture'
);

SELECT create_seed_listing(
  random_user_id(),
  'Boys clothes size 10-12',
  'son hit a growth spurt and outgrew everything overnight. mostly athletic wear and school clothes from target and walmart. all clean and good condition',
  ST_MakePoint(-118.2554, 34.1420),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free rabbit hutch and supplies',
  'Our bunny went to live with my sister who has more space. Outdoor hutch, water bottle, food dishes, hay rack. Everything needed for a happy rabbit.',
  ST_MakePoint(-118.1311, 34.0969),
  'free-stuff',
  'pet-supplies'
);

SELECT create_seed_listing(
  random_user_id(),
  'Engineering textbooks - various subjects',
  'Graduated from UCLA engineering program. Have calculus, physics, materials science, thermodynamics books. Some older editions but concepts are timeless.',
  ST_MakePoint(-117.9473, 34.1064),
  'free-stuff',
  'books'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free rowing machine - needs adjustment',
  'This rowing machine worked great until the resistance mechanism got stuck. Still slides smoothly, just cant adjust difficulty. Might be easy fix.',
  ST_MakePoint(-118.3640, 34.1808),
  'free-stuff',
  'fitness'
);

SELECT create_seed_listing(
  random_user_id(),
  'Infant swing and bouncer',
  'Baby outgrew these already! Battery powered swing and bouncer seat. Both have different music and vibration settings. Great for keeping little ones happy.',
  ST_MakePoint(-118.0370, 34.0154),
  'free-stuff',
  'baby'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free camping gear',
  'Decided camping isnt for us after one trip. Sleeping bags, camp chairs, lantern, cooler. Everything you need for outdoor adventures.',
  ST_MakePoint(-118.4011, 34.2367),
  'free-stuff',
  'outdoor'
);

SELECT create_seed_listing(
  random_user_id(),
  'Scrubs and medical uniforms size medium',
  'Changed careers from nursing. Have about 8 sets of scrubs in different colors. All Cherokee and FIGS brand. Clean and professional.',
  ST_MakePoint(-118.0808, 34.0761),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free rice cooker - works perfectly',
  'Upgraded to instant pot so dont need this rice cooker anymore. Makes perfect rice every time. 6 cup capacity, great for families.',
  ST_MakePoint(-118.2667, 34.0928),
  'free-stuff',
  'appliances'
);

SELECT create_seed_listing(
  random_user_id(),
  'Pull-up bar and resistance bands',
  'Finished my home workout phase and back to gym. Door frame pull-up bar and set of resistance bands with handles. Good for strength training.',
  ST_MakePoint(-118.1553, 34.0633),
  'free-stuff',
  'fitness'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free oil painting supplies',
  'Switched to digital art so dont need physical supplies. Oil paints, palette knives, brushes, canvas boards. Most tubes barely used.',
  ST_MakePoint(-118.0662, 33.9189),
  'free-stuff',
  'art'
);

SELECT create_seed_listing(
  random_user_id(),
  'Old iPhone 8 - cracked screen',
  'Upgraded phones but this one still works despite cracked screen. Good for parts or someone who wants to fix it. Unlocked to any carrier.',
  ST_MakePoint(-118.2370, 34.1843),
  'free-stuff',
  'electronics'
);

SELECT create_seed_listing(
  random_user_id(),
  'Patio furniture - needs cleaning',
  'Moving to apartment with no patio. Plastic table and 4 chairs, umbrella with stand. Needs good cleaning but structurally sound.',
  ST_MakePoint(-117.8953, 34.1058),
  'free-stuff',
  'outdoor'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free shipping boxes and mailers',
  'Run an online business and have accumulated tons of extra packaging. Various sized boxes, bubble mailers, packing tape. Perfect for online sellers.',
  ST_MakePoint(-118.4456, 34.0522),
  'free-stuff',
  'household'
);

SELECT create_seed_listing(
  random_user_id(),
  'Mens running shoes size 10',
  'bought wrong size online and missed return window. brand new nike running shoes, never worn. still in box with tags',
  ST_MakePoint(-118.1937, 33.8653),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free fish tank - 10 gallon',
  'Got out of the fish hobby and tank has been empty for months. Comes with filter, heater, gravel, decorations. Perfect starter setup.',
  ST_MakePoint(-118.3267, 34.2078),
  'free-stuff',
  'pet-supplies'
);

SELECT create_seed_listing(
  random_user_id(),
  'Printer - inkjet, needs new cartridges',
  'HP inkjet printer that works fine but needs new ink cartridges. Good for someone who prints occasionally and doesnt mind buying ink.',
  ST_MakePoint(-118.0912, 34.0145),
  'free-stuff',
  'electronics'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free Easter decorations',
  'Have way too many holiday decorations. Plastic eggs, bunny figurines, pastel garland, easter basket supplies. Great for families with kids.',
  ST_MakePoint(-118.2437, 34.0598),
  'free-stuff',
  'holiday'
);

SELECT create_seed_listing(
  random_user_id(),
  'Mens jeans size 34x32',
  'Lost weight and these are too big now. Mix of brands like levis and wrangler. some with minor wear but still have life left',
  ST_MakePoint(-118.1825, 34.1931),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free lamps and lighting',
  'Updated all my lighting and have old fixtures to give away. Table lamps, floor lamp, ceiling fan light kit. Mix of styles but all work.',
  ST_MakePoint(-117.9445, 33.8734),
  'free-stuff',
  'household'
);

SELECT create_seed_listing(
  random_user_id(),
  'Recumbent exercise bike - works great',
  'This bike has been perfect for low impact cardio but Im moving and cant take it. Comfortable seat, multiple resistance levels.',
  ST_MakePoint(-118.3871, 34.2367),
  'free-stuff',
  'fitness'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free tile samples and grout',
  'Leftover materials from bathroom renovation. Various ceramic tiles, grout, spacers, tile adhesive. Perfect for small DIY projects.',
  ST_MakePoint(-118.1108, 34.1064),
  'free-stuff',
  'building'
);

SELECT create_seed_listing(
  random_user_id(),
  'Young adult novels - fantasy series',
  'Daughter is in college now and doesnt read YA anymore. Hunger Games, Divergent, Percy Jackson series. All paperback in good condition.',
  ST_MakePoint(-118.0370, 33.9425),
  'free-stuff',
  'books'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free juicer and smoothie maker',
  'Went through a health kick phase and bought too many appliances. Centrifugal juicer and personal blender. Both work great for healthy drinks.',
  ST_MakePoint(-118.2927, 34.2078),
  'free-stuff',
  'appliances'
);

SELECT create_seed_listing(
  random_user_id(),
  'Motorcycle helmet and jacket',
  'Sold my bike but still have safety gear. DOT approved helmet size large, leather jacket size medium. Both in good condition.',
  ST_MakePoint(-118.5647, 34.0158),
  'free-stuff',
  'automotive'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free scrapbooking supplies',
  'Used to scrapbook but went digital. Decorative paper, stickers, albums, cutting tools, photo corners. Tons of supplies for memory keeping.',
  ST_MakePoint(-118.1553, 34.1931),
  'free-stuff',
  'art'
);

SELECT create_seed_listing(
  random_user_id(),
  'Phone accessories - various models',
  'Accumulated phone cases and chargers over the years. Mix of iPhone and Android accessories. Some may fit current models.',
  ST_MakePoint(-117.8953, 33.8734),
  'free-stuff',
  'electronics'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free jigsaw puzzles - 1000 pieces',
  'Have completed puzzle collection taking up storage space. All 1000+ piece puzzles with nature and travel themes. Perfect for puzzle enthusiasts.',
  ST_MakePoint(-118.4490, 34.1420),
  'free-stuff',
  'toys'
);

SELECT create_seed_listing(
  random_user_id(),
  'Vanity mirror and makeup organizer',
  'Simplified my beauty routine and dont need these anymore. Lighted vanity mirror and acrylic makeup organizer with compartments.',
  ST_MakePoint(-118.2554, 34.0969),
  'free-stuff',
  'household'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free succulent cuttings',
  'My succulent garden is overflowing! Have cuttings from various plants ready to root. Perfect for starting your own succulent collection.',
  ST_MakePoint(-118.1311, 34.0154),
  'free-stuff',
  'plants'
);

-- HELP NEEDED LISTINGS (15 listings)
SELECT create_seed_listing(
  random_user_id(),
  'need ride home from medical procedure',
  'having a minor procedure done thursday morning and need someone to give me a ride home afterwards. doctor says i cant drive for rest of the day. live in burbank, procedure is in glendale. happy to pay for gas',
  ST_MakePoint(-118.3089, 34.1808),
  'help-needed',
  'transportation',
  '45-min',
  NULL,
  'gas money'
);

SELECT create_seed_listing(
  random_user_id(),
  'Help getting heavy dresser upstairs',
  'Bought a dresser from facebook marketplace and need help carrying it up to my 3rd floor apartment. Its solid wood and really heavy. Should take about 30 minutes. Can buy you lunch afterwards!',
  ST_MakePoint(-118.0808, 34.0761),
  'help-needed',
  'moving',
  '30-min',
  '{"heavy lifting"}',
  'lunch'
);

SELECT create_seed_listing(
  random_user_id(),
  'bathroom sink wont drain properly',
  'sink has been draining super slow for weeks and now its completely backed up. tried draino but didnt work. need someone who knows plumbing to take a look. can pay reasonable rate',
  ST_MakePoint(-118.4011, 34.2367),
  'help-needed',
  'repair',
  '1-hour',
  '{"plumbing knowledge"}',
  'reasonable payment for repair'
);

SELECT create_seed_listing(
  random_user_id(),
  'Need help mounting TV on wall',
  'Got a wall mount for my TV but have no idea how to install it safely. Dont want it falling down! Need someone with tools and experience. Will provide dinner and drinks.',
  ST_MakePoint(-118.2370, 34.1843),
  'help-needed',
  'installation',
  '1-hour',
  '{"drill", "stud finder", "mounting experience"}',
  'dinner and drinks'
);

SELECT create_seed_listing(
  random_user_id(),
  'car battery died at work',
  'my car wont start and im stuck in the parking lot at my office in downtown LA. think the battery is dead. have cables but need someone to jump it. can venmo you for gas',
  ST_MakePoint(-118.2437, 34.0522),
  'help-needed',
  'automotive',
  '15-min',
  '{"car with good battery"}',
  'venmo for gas'
);

SELECT create_seed_listing(
  random_user_id(),
  'Help connecting new router and wifi',
  'Internet company installed new router but now nothing works right. Need someone who understands networking to help get everything connected properly again.',
  ST_MakePoint(-117.9473, 34.1064),
  'help-needed',
  'tech',
  '1-hour',
  '{"networking knowledge"}'
);

SELECT create_seed_listing(
  random_user_id(),
  'moving day help - loading truck',
  'rented a moving truck and need 2-3 people to help load boxes and furniture. everything is packed and ready to go. should take about 90 minutes. paying $25 per person cash',
  ST_MakePoint(-118.2589, 34.0522),
  'help-needed',
  'moving',
  '2-hours',
  '{"heavy lifting"}',
  '$25 per person cash'
);

SELECT create_seed_listing(
  random_user_id(),
  'Laptop screen cracked - need data backup',
  'Dropped my laptop and screen is completely cracked. Cant see anything but computer still turns on. Need someone to help me backup all my photos and documents.',
  ST_MakePoint(-118.1553, 34.0633),
  'help-needed',
  'tech',
  '2-hours',
  '{"computer skills", "external drive"}'
);

SELECT create_seed_listing(
  random_user_id(),
  'need someone to pick up prescription',
  'recovering from foot surgery and cant drive. need someone to pick up my medication from CVS and bring it to me. can pay you back plus $10 for your time',
  ST_MakePoint(-118.0662, 33.9189),
  'help-needed',
  'errands',
  '30-min',
  '{"car", "ID for pickup"}',
  'medication cost plus $10'
);

SELECT create_seed_listing(
  random_user_id(),
  'Garbage disposal is jammed',
  'Something got stuck in my garbage disposal and now it wont turn on. tried the reset button but nothing. need someone who knows about these things to fix it',
  ST_MakePoint(-118.3640, 34.1808),
  'help-needed',
  'repair',
  '45-min',
  '{"tools", "disposal knowledge"}',
  'will pay for parts and labor'
);

SELECT create_seed_listing(
  random_user_id(),
  'help putting together exercise equipment',
  'bought a home gym setup and the assembly instructions are impossible to understand. need someone patient who has done this kind of thing before. have all the tools',
  ST_MakePoint(-118.0370, 34.0154),
  'help-needed',
  'assembly',
  '2-hours',
  '{"patience", "assembly experience"}',
  'pizza and beer'
);

SELECT create_seed_listing(
  random_user_id(),
  'Front yard needs cleanup',
  'Yard is overgrown with weeds and needs serious help. Too much for me to handle alone. Need someone with experience doing yard work. Can pay $20/hour.',
  ST_MakePoint(-118.2927, 34.2078),
  'help-needed',
  'yard-work',
  '2-hours',
  '{"gardening tools", "yard work experience"}',
  '$20/hour'
);

SELECT create_seed_listing(
  random_user_id(),
  'need cat sitter for weekend',
  'going out of town for the weekend and need someone to check on my two cats. just need feeding and litter box cleaning. cats are very friendly and easy going',
  ST_MakePoint(-118.3456, 34.0736),
  'help-needed',
  'pet-care',
  'multiple-days',
  '{"comfortable with cats"}',
  '$40 for the weekend'
);

SELECT create_seed_listing(
  random_user_id(),
  'Help unloading delivery truck',
  'Having furniture delivered but delivery guys wont bring it inside. Need 2 people to help unload truck and carry stuff to my apartment. Heavy lifting involved.',
  ST_MakePoint(-118.1825, 34.1931),
  'help-needed',
  'moving',
  '1-hour',
  '{"heavy lifting"}',
  '$30 total to split'
);

SELECT create_seed_listing(
  random_user_id(),
  'confused about new smartphone',
  'just got a new phone and cant figure out how to transfer my contacts and photos from my old one. need someone patient who can teach me the basics. im 68 years old',
  ST_MakePoint(-117.9445, 33.8734),
  'help-needed',
  'tech',
  '1-hour',
  '{"smartphone knowledge", "patience with seniors"}'
);

-- SKILLS OFFERED LISTINGS (5 listings)
SELECT create_seed_listing(
  random_user_id(),
  'Free help with small electrical jobs',
  'Licensed electrician with free time on weekends. Happy to help with simple jobs like installing ceiling fans, replacing outlets, fixing light switches. Just want to help the community.',
  ST_MakePoint(-118.3871, 34.2367),
  'skills-offered',
  'electrical'
);

SELECT create_seed_listing(
  random_user_id(),
  'English tutoring for non-native speakers',
  'ESL teacher with 10 years experience. Offering free English conversation practice and grammar help for adults learning English. Can meet at coffee shops or library.',
  ST_MakePoint(-118.1108, 34.1064),
  'skills-offered',
  'tutoring'
);

SELECT create_seed_listing(
  random_user_id(),
  'automotive repairs - learning mechanic',
  'studying to be a mechanic and need practice working on different cars. can help with basic maintenance like oil changes, brake pads, tune-ups. you just pay for parts',
  ST_MakePoint(-118.0370, 33.9425),
  'skills-offered',
  'automotive'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free website help for small businesses',
  'Web developer wanting to build portfolio. Can help small businesses create simple websites, fix existing sites, or teach basic web maintenance. No charge.',
  ST_MakePoint(-118.2927, 34.2078),
  'skills-offered',
  'web-design'
);

SELECT create_seed_listing(
  random_user_id(),
  'Pet grooming practice needed',
  'Learning pet grooming and need dogs to practice on. Basic bath, brush, nail trim. Your dog gets pampered for free and I get practice. Win-win!',
  ST_MakePoint(-118.4370, 34.0520),
  'skills-offered',
  'pet-grooming'
);
