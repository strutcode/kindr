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
  ST_MakePoint(-118.5951, 33.9425),
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
  ST_MakePoint(-118.5647, 34.0158),
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
  ST_MakePoint(-118.5647, 34.0158),
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

-- MORE FREE STUFF LISTINGS (30 listings)
SELECT create_seed_listing(
  random_user_id(),
  'Free desk chair - needs minor repair',
  'Office chair that works but the height adjustment is stuck. Still comfortable for sitting. Would be perfect if someone handy can fix it. Pick up from Van Nuys.',
  ST_MakePoint(-118.4490, 34.1869),
  'free-stuff',
  'furniture'
);

SELECT create_seed_listing(
  random_user_id(),
  'kids winter clothes size 4T-6T',
  'my son outgrew all his winter stuff. jackets, sweaters, pants, boots. mix of brands like old navy and target. all clean and good condition',
  ST_MakePoint(-118.2554, 34.1420),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free aquarium - 20 gallon',
  'Used to have fish but got tired of maintaining it. Tank is clean, comes with filter, heater, and decorations. Perfect for someone wanting to start with fish.',
  ST_MakePoint(-118.1311, 34.0969),
  'free-stuff',
  'pet-supplies'
);

SELECT create_seed_listing(
  random_user_id(),
  'Textbooks - nursing and medical',
  'Finished nursing school and have books I dont need anymore. Anatomy, pharmacology, nursing fundamentals. Couple editions old but still useful for studying.',
  ST_MakePoint(-117.9473, 34.1064),
  'free-stuff',
  'books'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free treadmill - works but loud',
  'This treadmill runs fine but makes noise when you use it. Probably needs lubrication or something. Free to whoever wants to fix it up. Its really heavy tho',
  ST_MakePoint(-118.3640, 34.1808),
  'free-stuff',
  'sports'
);

SELECT create_seed_listing(
  random_user_id(),
  'Baby high chair and booster seat',
  'Both kids are older now so we dont need these anymore. High chair converts to booster seat. Some food stains but everything cleans up well. Smoke free home.',
  ST_MakePoint(-118.0370, 34.0154),
  'free-stuff',
  'baby'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free firewood logs',
  'Had some trees cut down and have good hardwood logs. They need to be split but great for fireplace or camping. You come pick them up from my driveway.',
  ST_MakePoint(-118.4011, 34.2367),
  'free-stuff',
  'outdoor'
);

SELECT create_seed_listing(
  random_user_id(),
  'womens business clothes size 10-12',
  'Changed careers and dont need professional clothes anymore. blazers, dress pants, skirts, blouses. mostly ann taylor and banana republic. good condition',
  ST_MakePoint(-118.0808, 34.0761),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free sewing machine - vintage singer',
  'This belonged to my grandmother. Its really old but still works. Perfect for someone who knows about vintage machines or wants to learn to sew.',
  ST_MakePoint(-118.5951, 33.9425),
  'free-stuff',
  'appliances'
);

SELECT create_seed_listing(
  random_user_id(),
  'Bike trainer for indoor cycling',
  'Used this during lockdown but now i go to gym. Converts regular bike into stationary bike. Good condition, just needs someone to use it again.',
  ST_MakePoint(-118.1553, 34.0633),
  'free-stuff',
  'sports'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free construction paper and art supplies',
  'Bought too much for my kids school project. Construction paper, markers, crayons, glue sticks, scissors. Perfect for teachers or parents with young kids.',
  ST_MakePoint(-118.0662, 33.9189),
  'free-stuff',
  'art'
);

SELECT create_seed_listing(
  random_user_id(),
  'Old stereo system with speakers',
  'This is from like the 90s but still works great. CD player, radio, tape deck. Good sound quality. Just dont have room for it anymore.',
  ST_MakePoint(-118.2370, 34.1843),
  'free-stuff',
  'electronics'
);

SELECT create_seed_listing(
  random_user_id(),
  'Garden hose and sprinkler attachments',
  'Moving to apartment so cant use these anymore. 50 foot hose plus various sprinkler heads and attachments. Some wear but still functional.',
  ST_MakePoint(-117.8953, 34.1058),
  'free-stuff',
  'garden'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free moving boxes - different sizes',
  'Just finished moving and have tons of boxes left over. Small, medium, large sizes. Some have tape residue but still sturdy. Save money on your move!',
  ST_MakePoint(-118.4456, 34.0522),
  'free-stuff',
  'household'
);

SELECT create_seed_listing(
  random_user_id(),
  'mens shoes size 11 - dress and casual',
  'cleaned out my closet and have shoes i never wear. dress shoes, sneakers, boots. mostly black and brown. some are barely worn',
  ST_MakePoint(-118.1937, 33.8653),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free cat carrier and supplies',
  'My cat passed away and I want these to help another cat family. Carrier, food bowls, toys, scratching post. Everything is clean and ready to use.',
  ST_MakePoint(-118.3267, 34.2078),
  'free-stuff',
  'pet-supplies'
);

SELECT create_seed_listing(
  random_user_id(),
  'Computer keyboard and mouse',
  'Got wireless ones so dont need these anymore. Standard keyboard and optical mouse. Both work perfectly, just need someone to use them.',
  ST_MakePoint(-118.0912, 34.0145),
  'free-stuff',
  'electronics'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free artificial Christmas tree',
  'Got a real tree this year so dont need the fake one. Its about 6 feet tall, pre-lit but some lights might be burned out. Comes with stand.',
  ST_MakePoint(-118.5315, 34.0158),
  'free-stuff',
  'holiday'
);

SELECT create_seed_listing(
  random_user_id(),
  'Maternity clothes size medium',
  'Done having babies so these need to go to someone who needs them. Tops, pants, dresses. Mix of seasons. All clean and comfortable.',
  ST_MakePoint(-118.1825, 34.1931),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free photo frames and albums',
  'Went digital with all my photos. Have picture frames in different sizes and some photo albums. Good for someone who still prints pictures.',
  ST_MakePoint(-117.9445, 33.8734),
  'free-stuff',
  'household'
);

SELECT create_seed_listing(
  random_user_id(),
  'Exercise bike - needs work',
  'This bike was great but now the resistance doesnt work right. Might be an easy fix for someone handy. Too heavy for me to throw away.',
  ST_MakePoint(-118.3871, 34.2367),
  'free-stuff',
  'sports'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free scrap wood for projects',
  'Leftover lumber from home improvements. Various sizes of plywood and 2x4s. Perfect for DIY projects or small repairs. You haul away.',
  ST_MakePoint(-118.1108, 34.1064),
  'free-stuff',
  'building'
);

SELECT create_seed_listing(
  random_user_id(),
  'Old textbooks - high school level',
  'Found these in storage from my kids high school years. Math, science, english, history. Older editions but good for reference or homeschooling.',
  ST_MakePoint(-118.0370, 33.9425),
  'free-stuff',
  'books'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free cookbooks and kitchen gadgets',
  'Downsizing my kitchen. Have cookbooks I never use and gadgets like can openers, measuring cups, mixing bowls. Take what you need.',
  ST_MakePoint(-118.2927, 34.2078),
  'free-stuff',
  'kitchen'
);

SELECT create_seed_listing(
  random_user_id(),
  'Car floor mats - universal fit',
  'Bought wrong size for my car. Still in package, rubber floor mats that should fit most cars. Paid $30, free to whoever needs them.',
  ST_MakePoint(-118.5647, 34.0158),
  'free-stuff',
  'automotive'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free fabric and sewing supplies',
  'Used to sew a lot but dont have time anymore. Different fabrics, thread, buttons, zippers. Perfect for someone who enjoys sewing projects.',
  ST_MakePoint(-118.1553, 34.1931),
  'free-stuff',
  'art'
);

SELECT create_seed_listing(
  random_user_id(),
  'Old laptop bag and accessories',
  'Got a new laptop that came with its own bag. This one is in good shape, has lots of pockets. Also have mouse pad and USB cables.',
  ST_MakePoint(-117.8953, 33.8734),
  'free-stuff',
  'electronics'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free board puzzles - 1000+ pieces',
  'Have about 6 jigsaw puzzles that are complete. Different themes like landscapes and animals. Good for family time or stress relief.',
  ST_MakePoint(-118.4490, 34.1420),
  'free-stuff',
  'toys'
);

SELECT create_seed_listing(
  random_user_id(),
  'Bathroom accessories - towel bars, etc',
  'Remodeled bathroom and have leftover hardware. Towel bars, toilet paper holder, hooks. Chrome finish, good condition.',
  ST_MakePoint(-118.2554, 34.0969),
  'free-stuff',
  'household'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free indoor plants - need rehoming',
  'Moving cross country and cant take my plants. Have pothos, snake plant, spider plant. All healthy but need someone to care for them.',
  ST_MakePoint(-118.1311, 34.0154),
  'free-stuff',
  'plants'
);

-- HELP NEEDED LISTINGS (15 unique listings - replacing second occurrence)
SELECT create_seed_listing(
  random_user_id(),
  'need transportation to airport early morning',
  'flight leaves at 6am and need someone to drive me to LAX. live in santa monica. will pay $40 plus parking if you want to stay and drive back with me',
  ST_MakePoint(-118.4912, 34.0194),
  'help-needed',
  'transportation',
  '1-hour',
  '{"early morning availability"}',
  '$40 plus parking'
);

SELECT create_seed_listing(
  random_user_id(),
  'Help carrying bookshelf to second floor',
  'Just bought a tall bookshelf from ikea and need help getting it upstairs. assembled it downstairs like an idiot. need 2 strong people to help me carry it up safely',
  ST_MakePoint(-118.2851, 34.0969),
  'help-needed',
  'moving',
  '45-min',
  '{"heavy lifting", "2 people needed"}',
  'beer and pizza'
);

SELECT create_seed_listing(
  random_user_id(),
  'shower head leaking and water pressure low',
  'shower has been acting weird for weeks. now the head is dripping constantly and barely any water comes out. tried cleaning it but didnt help. need a plumber',
  ST_MakePoint(-118.3774, 34.0567),
  'help-needed',
  'repair',
  '1-hour',
  '{"plumbing experience"}',
  '$75 for the job'
);

SELECT create_seed_listing(
  random_user_id(),
  'Need help installing ceiling fan',
  'bought a ceiling fan but the wiring looks complicated. need someone who knows electrical work to install it safely. already have ladder and basic tools',
  ST_MakePoint(-118.2278, 34.0928),
  'help-needed',
  'installation',
  '2-hours',
  '{"electrical knowledge", "ceiling fan experience"}',
  '$100 cash'
);

SELECT create_seed_listing(
  random_user_id(),
  'locked keys in car at grocery store',
  'just locked my keys in my car at ralphs. car is running and i have my phone but cant get in. need someone with lockout tools or know how to help',
  ST_MakePoint(-118.3644, 34.0394),
  'help-needed',
  'automotive',
  '30-min',
  '{"lockout tools or knowledge"}',
  'will pay $50'
);

SELECT create_seed_listing(
  random_user_id(),
  'Help setting up smart home devices',
  'bought google home, smart thermostat, and security cameras but have no idea how to connect everything. need someone tech savvy to help set it all up',
  ST_MakePoint(-118.1445, 34.1478),
  'help-needed',
  'tech',
  '2-hours',
  '{"smart home knowledge", "wifi setup"}',
  'dinner and $50'
);

SELECT create_seed_listing(
  random_user_id(),
  'need help organizing garage sale',
  'having a garage sale this weekend and need help pricing items and organizing everything. lots of stuff to sort through. early morning start',
  ST_MakePoint(-118.4637, 34.0522),
  'help-needed',
  'organization',
  '4-hours',
  '{"early morning availability"}',
  'keep 20% of sales'
);

SELECT create_seed_listing(
  random_user_id(),
  'iPhone dropped in water - need data recovery',
  'dropped my phone in the pool and now it wont turn on. really need my photos and contacts recovered if possible. willing to pay well for professional help',
  ST_MakePoint(-118.2520, 34.0687),
  'help-needed',
  'tech',
  '2-hours',
  '{"phone repair experience", "data recovery tools"}',
  'up to $200 if successful'
);

SELECT create_seed_listing(
  random_user_id(),
  'help with grocery shopping for elderly parent',
  'my mom is 85 and cant get around well anymore. need someone reliable to do her weekly grocery shopping. she has a list and money ready',
  ST_MakePoint(-118.2889, 34.0224),
  'help-needed',
  'errands',
  '2-hours',
  '{"car", "patient with elderly"}',
  '$30 per trip'
);

SELECT create_seed_listing(
  random_user_id(),
  'washing machine making loud noises',
  'washing machine sounds like its going to explode when it spins. clothes still get clean but the noise is horrible. need someone to diagnose the problem',
  ST_MakePoint(-118.3896, 34.0736),
  'help-needed',
  'repair',
  '1-hour',
  '{"appliance repair knowledge"}',
  'will pay diagnostic fee'
);

SELECT create_seed_listing(
  random_user_id(),
  'need help building raised garden beds',
  'want to build 3 raised beds in my backyard but have no carpentry skills. have all the materials and tools. just need someone who knows what theyre doing',
  ST_MakePoint(-118.2566, 34.0466),
  'help-needed',
  'construction',
  '5-hours',
  '{"carpentry skills", "garden bed building"}',
  '$150 for the day'
);

SELECT create_seed_listing(
  random_user_id(),
  'backyard is completely overgrown',
  'havent done yard work in months and now its a jungle back there. need someone with serious landscaping equipment to help tame it. big job',
  ST_MakePoint(-118.4456, 34.0598),
  'help-needed',
  'yard-work',
  '6-hours',
  '{"landscaping equipment", "heavy yard work"}',
  '$25/hour'
);

SELECT create_seed_listing(
  random_user_id(),
  'need dog walker for injured dog',
  'my dog hurt his leg and cant go on long walks but still needs gentle exercise. need someone experienced with injured pets to walk him slowly',
  ST_MakePoint(-118.2019, 34.0522),
  'help-needed',
  'pet-care',
  '30-min daily',
  '{"experience with injured pets"}',
  '$20 per walk'
);

SELECT create_seed_listing(
  random_user_id(),
  'Help moving piano to new house',
  'need experienced piano movers to help relocate my upright piano. its really heavy and i dont want to damage it. professional job needed',
  ST_MakePoint(-118.3311, 34.0981),
  'help-needed',
  'moving',
  '2-hours',
  '{"piano moving experience", "specialized equipment"}',
  '$300 for the job'
);

SELECT create_seed_listing(
  random_user_id(),
  'help learning to use computer for senior',
  'just got my first computer at age 72 and feel completely lost. need someone very patient to teach me email, internet, and basic stuff. willing to pay for lessons',
  ST_MakePoint(-118.2889, 34.0677),
  'help-needed',
  'tech',
  '2-hours',
  '{"computer teaching", "patience with seniors"}',
  '$40 per lesson'
);

-- SKILLS OFFERED LISTINGS (5 unique listings - replacing second occurrence)
SELECT create_seed_listing(
  random_user_id(),
  'Free guitar lessons for beginners',
  'Been playing guitar for 15 years and want to share the love of music. Offering free beginner lessons on weekends. Bring your own guitar or I have extras.',
  ST_MakePoint(-118.2623, 34.1341),
  'skills-offered',
  'music'
);

SELECT create_seed_listing(
  random_user_id(),
  'Resume writing help - no charge',
  'HR professional offering free resume reviews and rewrites. Helped many people land jobs. Just want to give back to the community during tough times.',
  ST_MakePoint(-118.2437, 34.0736),
  'skills-offered',
  'career'
);

SELECT create_seed_listing(
  random_user_id(),
  'bicycle repair and maintenance',
  'learning bike mechanics and need practice. can help with basic repairs like flat tires, brake adjustments, tune-ups. you just pay for any parts needed',
  ST_MakePoint(-118.3774, 34.0394),
  'skills-offered',
  'bicycle'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free photography sessions for families',
  'Building my portrait photography portfolio and need families to practice with. Free photo sessions, you get digital copies of all the good shots.',
  ST_MakePoint(-118.2851, 34.0522),
  'skills-offered',
  'photography'
);

SELECT create_seed_listing(
  random_user_id(),
  'Math tutoring for middle and high school',
  'Retired math teacher with 30 years experience. Happy to help students struggling with algebra, geometry, or pre-calc. Free tutoring at local library.',
  ST_MakePoint(-118.4912, 34.0736),
  'skills-offered',
  'tutoring'
);

-- ADDITIONAL USERS FOR GREATER LA AREA (20 more users)
SELECT create_seed_user('Luis Ramirez', 'luis.ramirez.sfv@gmail.com');
SELECT create_seed_user('Hannah Schmidt', 'hannah.schmidt@yahoo.com');
SELECT create_seed_user('Jake Thompson', 'jake.thompson.burbank@outlook.com');
SELECT create_seed_user('Aria Patel', 'aria.patel@gmail.com');
SELECT create_seed_user('Marcus Williams', 'marcus.williams.glendale@hotmail.com');
SELECT create_seed_user('Sofia Gonzalez', 'sofia.gonzalez@gmail.com');
SELECT create_seed_user('Ethan Park', 'ethan.park.torrance@yahoo.com');
SELECT create_seed_user('Maya Singh', 'maya.singh@gmail.com');
SELECT create_seed_user('Connor Brady', 'connor.brady@outlook.com');
SELECT create_seed_user('Layla Ahmed', 'layla.ahmed.alhambra@gmail.com');
SELECT create_seed_user('Owen Mitchell', 'owen.mitchell@yahoo.com');
SELECT create_seed_user('Zara Khan', 'zara.khan.manhattan@hotmail.com');
SELECT create_seed_user('Blake Rodriguez', 'blake.rodriguez@gmail.com');
SELECT create_seed_user('Nora Chen', 'nora.chen.arcadia@outlook.com');
SELECT create_seed_user('Ian Foster', 'ian.foster@yahoo.com');
SELECT create_seed_user('Lily Moreno', 'lily.moreno.whittier@gmail.com');
SELECT create_seed_user('Caleb Jones', 'caleb.jones@hotmail.com');
SELECT create_seed_user('Ruby Nakamura', 'ruby.nakamura@gmail.com');
SELECT create_seed_user('Mason Torres', 'mason.torres.pomona@outlook.com');
SELECT create_seed_user('Stella Kim', 'stella.kim.monterey@yahoo.com');

-- ADDITIONAL LISTINGS FOR GREATER LA AREA (50 more listings)

-- MORE FREE STUFF LISTINGS (30 listings)
SELECT create_seed_listing(
  random_user_id(),
  'Free desk chair - needs minor repair',
  'Office chair that works but the height adjustment is stuck. Still comfortable for sitting. Would be perfect if someone handy can fix it. Pick up from Van Nuys.',
  ST_MakePoint(-118.4490, 34.1869),
  'free-stuff',
  'furniture'
);

SELECT create_seed_listing(
  random_user_id(),
  'kids winter clothes size 4T-6T',
  'my son outgrew all his winter stuff. jackets, sweaters, pants, boots. mix of brands like old navy and target. all clean and good condition',
  ST_MakePoint(-118.2554, 34.1420),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free aquarium - 20 gallon',
  'Used to have fish but got tired of maintaining it. Tank is clean, comes with filter, heater, and decorations. Perfect for someone wanting to start with fish.',
  ST_MakePoint(-118.1311, 34.0969),
  'free-stuff',
  'pet-supplies'
);

SELECT create_seed_listing(
  random_user_id(),
  'Textbooks - nursing and medical',
  'Finished nursing school and have books I dont need anymore. Anatomy, pharmacology, nursing fundamentals. Couple editions old but still useful for studying.',
  ST_MakePoint(-117.9473, 34.1064),
  'free-stuff',
  'books'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free treadmill - works but loud',
  'This treadmill runs fine but makes noise when you use it. Probably needs lubrication or something. Free to whoever wants to fix it up. Its really heavy tho',
  ST_MakePoint(-118.3640, 34.1808),
  'free-stuff',
  'sports'
);

SELECT create_seed_listing(
  random_user_id(),
  'Baby high chair and booster seat',
  'Both kids are older now so we dont need these anymore. High chair converts to booster seat. Some food stains but everything cleans up well. Smoke free home.',
  ST_MakePoint(-118.0370, 34.0154),
  'free-stuff',
  'baby'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free firewood logs',
  'Had some trees cut down and have good hardwood logs. They need to be split but great for fireplace or camping. You come pick them up from my driveway.',
  ST_MakePoint(-118.4011, 34.2367),
  'free-stuff',
  'outdoor'
);

SELECT create_seed_listing(
  random_user_id(),
  'womens business clothes size 10-12',
  'Changed careers and dont need professional clothes anymore. blazers, dress pants, skirts, blouses. mostly ann taylor and banana republic. good condition',
  ST_MakePoint(-118.0808, 34.0761),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free sewing machine - vintage singer',
  'This belonged to my grandmother. Its really old but still works. Perfect for someone who knows about vintage machines or wants to learn to sew.',
  ST_MakePoint(-118.5951, 33.9425),
  'free-stuff',
  'appliances'
);

SELECT create_seed_listing(
  random_user_id(),
  'Bike trainer for indoor cycling',
  'Used this during lockdown but now i go to gym. Converts regular bike into stationary bike. Good condition, just needs someone to use it again.',
  ST_MakePoint(-118.1553, 34.0633),
  'free-stuff',
  'sports'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free construction paper and art supplies',
  'Bought too much for my kids school project. Construction paper, markers, crayons, glue sticks, scissors. Perfect for teachers or parents with young kids.',
  ST_MakePoint(-118.0662, 33.9189),
  'free-stuff',
  'art'
);

SELECT create_seed_listing(
  random_user_id(),
  'Old stereo system with speakers',
  'This is from like the 90s but still works great. CD player, radio, tape deck. Good sound quality. Just dont have room for it anymore.',
  ST_MakePoint(-118.2370, 34.1843),
  'free-stuff',
  'electronics'
);

SELECT create_seed_listing(
  random_user_id(),
  'Garden hose and sprinkler attachments',
  'Moving to apartment so cant use these anymore. 50 foot hose plus various sprinkler heads and attachments. Some wear but still functional.',
  ST_MakePoint(-117.8953, 34.1058),
  'free-stuff',
  'garden'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free moving boxes - different sizes',
  'Just finished moving and have tons of boxes left over. Small, medium, large sizes. Some have tape residue but still sturdy. Save money on your move!',
  ST_MakePoint(-118.4456, 34.0522),
  'free-stuff',
  'household'
);

SELECT create_seed_listing(
  random_user_id(),
  'mens shoes size 11 - dress and casual',
  'cleaned out my closet and have shoes i never wear. dress shoes, sneakers, boots. mostly black and brown. some are barely worn',
  ST_MakePoint(-118.1937, 33.8653),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free cat carrier and supplies',
  'My cat passed away and I want these to help another cat family. Carrier, food bowls, toys, scratching post. Everything is clean and ready to use.',
  ST_MakePoint(-118.3267, 34.2078),
  'free-stuff',
  'pet-supplies'
);

SELECT create_seed_listing(
  random_user_id(),
  'Computer keyboard and mouse',
  'Got wireless ones so dont need these anymore. Standard keyboard and optical mouse. Both work perfectly, just need someone to use them.',
  ST_MakePoint(-118.0912, 34.0145),
  'free-stuff',
  'electronics'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free artificial Christmas tree',
  'Got a real tree this year so dont need the fake one. Its about 6 feet tall, pre-lit but some lights might be burned out. Comes with stand.',
  ST_MakePoint(-118.5315, 34.0158),
  'free-stuff',
  'holiday'
);

SELECT create_seed_listing(
  random_user_id(),
  'Maternity clothes size medium',
  'Done having babies so these need to go to someone who needs them. Tops, pants, dresses. Mix of seasons. All clean and comfortable.',
  ST_MakePoint(-118.1825, 34.1931),
  'free-stuff',
  'clothing'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free photo frames and albums',
  'Went digital with all my photos. Have picture frames in different sizes and some photo albums. Good for someone who still prints pictures.',
  ST_MakePoint(-117.9445, 33.8734),
  'free-stuff',
  'household'
);

SELECT create_seed_listing(
  random_user_id(),
  'Exercise bike - needs work',
  'This bike was great but now the resistance doesnt work right. Might be an easy fix for someone handy. Too heavy for me to throw away.',
  ST_MakePoint(-118.3871, 34.2367),
  'free-stuff',
  'sports'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free scrap wood for projects',
  'Leftover lumber from home improvements. Various sizes of plywood and 2x4s. Perfect for DIY projects or small repairs. You haul away.',
  ST_MakePoint(-118.1108, 34.1064),
  'free-stuff',
  'building'
);

SELECT create_seed_listing(
  random_user_id(),
  'Old textbooks - high school level',
  'Found these in storage from my kids high school years. Math, science, english, history. Older editions but good for reference or homeschooling.',
  ST_MakePoint(-118.0370, 33.9425),
  'free-stuff',
  'books'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free cookbooks and kitchen gadgets',
  'Downsizing my kitchen. Have cookbooks I never use and gadgets like can openers, measuring cups, mixing bowls. Take what you need.',
  ST_MakePoint(-118.2927, 34.2078),
  'free-stuff',
  'kitchen'
);

SELECT create_seed_listing(
  random_user_id(),
  'Car floor mats - universal fit',
  'Bought wrong size for my car. Still in package, rubber floor mats that should fit most cars. Paid $30, free to whoever needs them.',
  ST_MakePoint(-118.5647, 34.0158),
  'free-stuff',
  'automotive'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free fabric and sewing supplies',
  'Used to sew a lot but dont have time anymore. Different fabrics, thread, buttons, zippers. Perfect for someone who enjoys sewing projects.',
  ST_MakePoint(-118.1553, 34.1931),
  'free-stuff',
  'art'
);

SELECT create_seed_listing(
  random_user_id(),
  'Old laptop bag and accessories',
  'Got a new laptop that came with its own bag. This one is in good shape, has lots of pockets. Also have mouse pad and USB cables.',
  ST_MakePoint(-117.8953, 33.8734),
  'free-stuff',
  'electronics'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free board puzzles - 1000+ pieces',
  'Have about 6 jigsaw puzzles that are complete. Different themes like landscapes and animals. Good for family time or stress relief.',
  ST_MakePoint(-118.4490, 34.1420),
  'free-stuff',
  'toys'
);

SELECT create_seed_listing(
  random_user_id(),
  'Bathroom accessories - towel bars, etc',
  'Remodeled bathroom and have leftover hardware. Towel bars, toilet paper holder, hooks. Chrome finish, good condition.',
  ST_MakePoint(-118.2554, 34.0969),
  'free-stuff',
  'household'
);

SELECT create_seed_listing(
  random_user_id(),
  'Free indoor plants - need rehoming',
  'Moving cross country and cant take my plants. Have pothos, snake plant, spider plant. All healthy but need someone to care for them.',
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
  ST_MakePoint(-118.5951, 33.9425),
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
  ST_MakePoint(-118.5647, 34.0158),
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
  ST_MakePoint(-118.5647, 34.0158),
  'skills-offered',
  'pet-grooming'
);
