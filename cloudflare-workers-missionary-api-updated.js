// Enhanced Missionary Profiles API for Cloudflare Workers
// Updated to include 6 comprehensive missionary profiles

// Complete missionary profiles data including original 3 + new 3 enhanced profiles
const MISSIONARY_PROFILES = [
  // Original profiles (William Carey, Hudson Taylor, Amy Carmichael) - Enhanced
  {
    "id": "william-carey",
    "name": "William Carey",
    "displayName": "William Carey - Father of Modern Missions",
    "dates": {
      "birth": 1761,
      "death": 1834,
      "display": "1761-1834"
    },
    "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/William_Carey.jpg/250px-William_Carey.jpg",
    "images": [
      "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/William_Carey.jpg/250px-William_Carey.jpg"
    ],
    "summary": "English Baptist missionary and polyglot who became known as the 'Father of Modern Missions' for his pioneering work in India, translating the Bible into multiple Indian languages.",
    "biography": [
      {
        "title": "Early Life and Calling",
        "content": "Born in Paulerspury, Northamptonshire, England, William Carey began life as a shoemaker. Despite limited formal education, he taught himself Latin, Greek, Hebrew, and other languages while working. A profound spiritual awakening led him to become a Baptist minister and develop a passion for world missions."
      },
      {
        "title": "The Great Commission Realized",
        "content": "In 1792, Carey preached his famous sermon 'Expect great things from God; attempt great things for God' and wrote 'An Enquiry into the Obligations of Christians to use Means for the Conversion of the Heathens,' which became the charter for the modern missionary movement."
      },
      {
        "title": "Mission to India",
        "content": "Arriving in India in 1793, Carey faced tremendous hardships including financial struggles, family illness, and initial resistance to his message. He worked for years without a single convert, demonstrating remarkable perseverance in the face of apparent failure."
      },
      {
        "title": "Translation Pioneer",
        "content": "Carey's greatest achievement was his translation work. He translated the complete Bible into Bengali, Oriya, Marathi, Hindi, Assamese, and Sanskrit, and portions into 29 other languages. His linguistic work laid the foundation for modern Bible translation methodology."
      },
      {
        "title": "Educational and Social Reform",
        "content": "Beyond evangelism, Carey established schools, founded Serampore College (India's first degree-granting institution), introduced printing presses, and campaigned against social evils like sati (widow burning) and infanticide, demonstrating the holistic nature of his mission."
      }
    ],
    "timeline": [
      {
        "year": 1761,
        "title": "Birth in England",
        "description": "Born in Paulerspury, Northamptonshire, to a weaver's family.",
        "type": "birth",
        "significance": "Humble beginnings that would lead to extraordinary global impact."
      },
      {
        "year": 1792,
        "title": "Famous Sermon",
        "description": "Preached 'Expect great things from God; attempt great things for God.'",
        "type": "calling",
        "significance": "Launched the modern missionary movement with this pivotal message."
      },
      {
        "year": 1793,
        "title": "Arrival in India",
        "description": "Reached Calcutta with his family after a five-month voyage.",
        "type": "arrival",
        "significance": "Beginning of 41 years of missionary service in India."
      },
      {
        "year": 1800,
        "title": "First Convert",
        "description": "Krishna Pal became the first Bengali convert after seven years of ministry.",
        "type": "ministry",
        "significance": "Breakthrough after years of apparent failure, validating his perseverance."
      },
      {
        "year": 1801,
        "title": "New Testament Published",
        "description": "Published the first Bengali New Testament translation.",
        "type": "translation",
        "significance": "First of many groundbreaking Bible translations."
      },
      {
        "year": 1818,
        "title": "Complete Bible",
        "description": "Completed the full Bengali Bible translation.",
        "type": "translation",
        "significance": "Monumental achievement providing Scripture in the people's language."
      },
      {
        "year": 1821,
        "title": "Serampore College Founded",
        "description": "Established India's first degree-granting institution.",
        "type": "education",
        "significance": "Created lasting educational infrastructure for India."
      },
      {
        "year": 1834,
        "title": "Death and Legacy",
        "description": "Died in Serampore, leaving behind translations in over 40 languages.",
        "type": "death",
        "significance": "His death marked the end of an era but his legacy continued worldwide."
      }
    ],
    "locations": [
      {
        "name": "Serampore, West Bengal",
        "coordinates": [22.7488, 88.3426],
        "type": "primary_ministry",
        "description": "Danish settlement where Carey established his mission station and college.",
        "years": "1800-1834",
        "significance": "Center of his translation work and educational ministry."
      },
      {
        "name": "Calcutta (Kolkata), West Bengal",
        "coordinates": [22.5726, 88.3639],
        "type": "ministry_location",
        "description": "Major city where Carey first arrived and conducted ministry.",
        "years": "1793-1800",
        "significance": "Gateway to India and initial ministry base."
      }
    ],
    "categories": ["missionary", "translator", "educator", "reformer"],
    "achievements": [
      "Translated Bible into 6 complete languages and portions into 29 others",
      "Founded Serampore College, India's first degree-granting institution",
      "Established first printing press in India",
      "Campaigned against sati (widow burning) and infanticide",
      "Called 'Father of Modern Missions' for launching the missionary movement"
    ],
    "quiz": [
      {
        "question": "What was William Carey's occupation before becoming a missionary?",
        "options": [
          "Teacher",
          "Shoemaker",
          "Farmer", 
          "Soldier"
        ],
        "correct": 1,
        "explanation": "William Carey was a shoemaker by trade. Despite his humble occupation and limited formal education, he taught himself multiple languages and became one of history's greatest Bible translators."
      },
      {
        "question": "How many years did Carey work in India before his first convert?",
        "options": [
          "3 years",
          "5 years",
          "7 years",
          "10 years"
        ],
        "correct": 2,
        "explanation": "Carey worked for seven long years before Krishna Pal became his first Bengali convert in 1800. This period of apparent 'failure' demonstrated his remarkable perseverance and faith."
      }
    ],
    "source": "wikimedia",
    "sourceUrl": "https://en.wikipedia.org/wiki/William_Carey_(missionary)",
    "attribution": "Based on Wikipedia and historical sources",
    "lastModified": "2025-01-27T22:00:00Z",
    "lang": "en"
  },
  {
    "id": "hudson-taylor",
    "name": "James Hudson Taylor",
    "displayName": "Hudson Taylor - Founder of China Inland Mission",
    "dates": {
      "birth": 1832,
      "death": 1905,
      "display": "1832-1905"
    },
    "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/HudsonTaylorin1893.jpg/250px-HudsonTaylorin1893.jpg",
    "images": [
      "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/HudsonTaylorin1893.jpg/250px-HudsonTaylorin1893.jpg"
    ],
    "summary": "British Protestant missionary to China and founder of the China Inland Mission, who pioneered innovative missionary methods and devoted 51 years to evangelizing inland China.",
    "biography": [
      {
        "title": "Early Life and Divine Calling",
        "content": "Born in Barnsley, Yorkshire, to devout Methodist parents, Hudson Taylor felt called to missionary service as a teenager. His spiritual awakening came through his mother's prayers and his own earnest seeking, leading to a deep conviction to serve in China."
      },
      {
        "title": "First Journey to China",
        "content": "At age 21, Taylor sailed for China in 1853 under the Chinese Evangelization Society. His early experiences in Shanghai taught him the importance of cultural adaptation and the limitations of traditional Western missionary approaches confined to coastal cities."
      },
      {
        "title": "Innovative Missionary Philosophy",
        "content": "Taylor developed revolutionary missionary principles: adopting Chinese dress and customs, focusing on China's unreached interior, relying entirely on faith for financial support without making appeals for funds, and recruiting missionaries from all social classes, not just the educated elite."
      },
      {
        "title": "Founding China Inland Mission",
        "content": "In 1865, while walking on Brighton beach, Taylor received a divine vision to evangelize inland China. He founded the China Inland Mission (later OMF International), which became the largest missionary organization in the world, eventually sending over 800 missionaries to China."
      },
      {
        "title": "Legacy of Faith and Sacrifice",
        "content": "Taylor's 51 years of service included tremendous personal costs: the deaths of his first wife Maria and several children, political upheavals, and constant dangers. Yet his faith-based approach revolutionized missions and influenced countless organizations worldwide."
      }
    ],
    "timeline": [
      {
        "year": 1832,
        "title": "Birth in Yorkshire",
        "description": "Born in Barnsley, Yorkshire, England, to Methodist parents James and Amelia Taylor.",
        "type": "birth",
        "significance": "Born into a devout Christian family that shaped his future missionary calling."
      },
      {
        "year": 1849,
        "title": "Spiritual Awakening",
        "description": "Experienced profound conversion at age 17, sensing God's call to China.",
        "type": "calling",
        "significance": "Life-changing experience that determined his future direction toward China."
      },
      {
        "year": 1853,
        "title": "First Voyage to China",
        "description": "Sailed to China at age 21 under the Chinese Evangelization Society.",
        "type": "departure",
        "significance": "Beginning of 51 years of service in China, longer than any other Protestant missionary."
      },
      {
        "year": 1858,
        "title": "Marriage to Maria Dyer",
        "description": "Married Maria Dyer, daughter of missionaries, who became his ministry partner.",
        "type": "personal",
        "significance": "Partnership that strengthened his ministry and produced future missionary children."
      },
      {
        "year": 1865,
        "title": "Brighton Beach Vision",
        "description": "Received divine vision on Brighton Beach to evangelize China's interior.",
        "type": "calling",
        "significance": "Pivotal moment leading to the founding of China Inland Mission."
      },
      {
        "year": 1866,
        "title": "Lammermuir Party Sails",
        "description": "Led 16 missionaries (the Lammermuir Party) to inland China.",
        "type": "ministry",
        "significance": "First systematic attempt to reach China's unreached interior regions."
      },
      {
        "year": 1870,
        "title": "Yangzhou Riot",
        "description": "Survived violent anti-foreign riot in Yangzhou that nearly claimed his life.",
        "type": "persecution",
        "significance": "Demonstrated the dangers faced by inland missionaries but confirmed his commitment."
      },
      {
        "year": 1905,
        "title": "Death in China",
        "description": "Died in Changsha, China, after 51 years of missionary service.",
        "type": "death",
        "significance": "Died in the land he loved, having established a lasting missionary legacy."
      }
    ],
    "locations": [
      {
        "name": "Ningbo, Zhejiang",
        "coordinates": [29.8683, 121.5440],
        "type": "early_ministry",
        "description": "Early ministry base where Taylor learned Chinese culture and language.",
        "years": "1857-1860",
        "significance": "Where he developed his philosophy of cultural adaptation."
      },
      {
        "name": "Yangzhou, Jiangsu",
        "coordinates": [32.4085, 119.4331],
        "type": "inland_mission",
        "description": "Inland city where Taylor established China Inland Mission work.",
        "years": "1868-1870",
        "significance": "Represented the breakthrough into China's unreached interior."
      }
    ],
    "categories": ["missionary", "evangelist", "organization_founder", "cultural_adapter"],
    "achievements": [
      "Founded China Inland Mission, world's largest missionary organization",
      "Pioneered faith-based missionary funding without appeals",
      "Sent over 800 missionaries to inland China",
      "Established over 300 mission stations across China",
      "Influenced modern missionary movement with cultural adaptation principles"
    ],
    "quiz": [
      {
        "question": "What revolutionary approach did Hudson Taylor take to missionary funding?",
        "options": [
          "He charged fees for his services",
          "He relied entirely on faith without making financial appeals",
          "He was supported by wealthy patrons",
          "He worked secular jobs to fund his ministry"
        ],
        "correct": 1,
        "explanation": "Taylor's China Inland Mission operated entirely by faith, never making appeals for funds or going into debt. This radical approach trusted God alone to provide through the prayers and voluntary gifts of supporters."
      },
      {
        "question": "How did Taylor adapt to Chinese culture?",
        "options": [
          "He learned only basic Chinese phrases",
          "He maintained Western dress and customs",
          "He adopted Chinese dress, queue hairstyle, and customs",
          "He refused to eat Chinese food"
        ],
        "correct": 2,
        "explanation": "Taylor shocked the missionary community by adopting Chinese dress, wearing a queue (traditional braided hairstyle), and embracing Chinese customs. This cultural adaptation helped him reach people in China's interior where foreigners were rarely welcomed."
      }
    ],
    "source": "wikimedia",
    "sourceUrl": "https://en.wikipedia.org/wiki/Hudson_Taylor",
    "attribution": "Based on Wikipedia and historical sources",
    "lastModified": "2025-01-27T22:00:00Z",
    "lang": "en"
  },
  {
    "id": "amy-carmichael",
    "name": "Amy Carmichael",
    "displayName": "Amy Carmichael - Rescuer of Temple Children in India",
    "dates": {
      "birth": 1867,
      "death": 1951,
      "display": "1867-1951"
    },
    "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Amy_Carmichael_with_children2.jpg/250px-Amy_Carmichael_with_children2.jpg",
    "images": [
      "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Amy_Carmichael_with_children2.jpg/250px-Amy_Carmichael_with_children2.jpg"
    ],
    "summary": "Irish missionary to India who devoted her life to rescuing children from temple prostitution and established the Dohnavur Fellowship, becoming a voice for the voiceless in South India.",
    "biography": [
      {
        "title": "Early Life and Calling",
        "content": "Born in Northern Ireland to a devout Presbyterian family, Amy Carmichael showed early signs of compassion and spiritual sensitivity. A defining moment came when she helped an elderly woman, and God spoke to her about caring for those society overlooked. Her calling to missions was confirmed through various spiritual experiences and a deep burden for the unreached."
      },
      {
        "title": "Journey to India",
        "content": "After brief missionary work in Japan, Amy felt called to India in 1895. She joined the Church of England Zenana Missionary Society and worked in various locations before settling in Tamil Nadu. Her willingness to adopt Indian dress and customs helped her gain acceptance among local people."
      },
      {
        "title": "Discovery of Temple Children",
        "content": "In 1901, a young girl named Preena escaped from temple prostitution and found refuge with Amy. This opened Amy's eyes to the horrific practice of dedicating young children to temples for religious prostitution. Despite denial from authorities and religious leaders, Amy courageously exposed this evil practice."
      },
      {
        "title": "Establishing Dohnavur Fellowship",
        "content": "Amy founded the Dohnavur Fellowship as a sanctuary for rescued children. The compound grew to include nurseries, schools, workshops, and a hospital. She created a family atmosphere where rescued children could heal, learn, and grow in safety and love, with many becoming Christian workers themselves."
      },
      {
        "title": "Literary Ministry and Legacy",
        "content": "Despite being bedridden for the last 20 years of her life due to a fall, Amy wrote 35 books that inspired generations of missionaries and Christians. Her writings combined practical wisdom, spiritual depth, and poetic beauty, while her rescue work saved thousands of children from exploitation."
      }
    ],
    "timeline": [
      {
        "year": 1867,
        "title": "Birth in Northern Ireland",
        "description": "Born in Millisle, County Down, Northern Ireland, to David and Catherine Carmichael.",
        "type": "birth",
        "significance": "Born into a loving Christian family that nurtured her faith and compassion."
      },
      {
        "year": 1885,
        "title": "Ministry to Mill Girls",
        "description": "Started ministry to mill girls in Belfast, establishing 'The Welcome' hall.",
        "type": "ministry",
        "significance": "Early demonstration of her heart for society's marginalized and forgotten."
      },
      {
        "year": 1895,
        "title": "Arrival in India",
        "description": "Arrived in India as missionary with the Church of England Zenana Missionary Society.",
        "type": "arrival",
        "significance": "Beginning of 56 years of service in India without a single furlough home."
      },
      {
        "year": 1901,
        "title": "Preena's Escape",
        "description": "Seven-year-old Preena escaped temple prostitution and found refuge with Amy.",
        "type": "calling",
        "significance": "Eye-opening event that revealed the hidden evil of temple child prostitution."
      },
      {
        "year": 1904,
        "title": "Dohnavur Fellowship Founded",
        "description": "Established permanent compound for rescued children in Dohnavur.",
        "type": "ministry",
        "significance": "Created safe haven that would rescue thousands of children over decades."
      },
      {
        "year": 1931,
        "title": "Serious Accident",
        "description": "Fell into a pit, sustaining injuries that left her largely bedridden.",
        "type": "injury",
        "significance": "Despite physical limitations, continued ministry through writing and leadership."
      },
      {
        "year": 1939,
        "title": "Major Literary Work",
        "description": "Published 'Gold Cord,' documenting her rescue work and spiritual insights.",
        "type": "writing",
        "significance": "Shared her experiences with global audience, inspiring others to action."
      },
      {
        "year": 1951,
        "title": "Death in India",
        "description": "Died in Dohnavur at age 83, having never returned to her homeland.",
        "type": "death",
        "significance": "Ended a life of complete dedication to India's children and the Gospel."
      }
    ],
    "locations": [
      {
        "name": "Dohnavur, Tamil Nadu",
        "coordinates": [8.3379, 77.2619],
        "type": "primary_ministry",
        "description": "Location of her fellowship compound and lifelong ministry base.",
        "years": "1904-1951",
        "significance": "Sanctuary that provided safety and hope for thousands of rescued children."
      },
      {
        "name": "Tirunelveli District, Tamil Nadu",
        "coordinates": [8.7139, 77.7567],
        "type": "regional_ministry",
        "description": "Broader region where she conducted evangelistic work and child rescue.",
        "years": "1901-1951",
        "significance": "Area where temple prostitution was prevalent and her work was most needed."
      }
    ],
    "categories": ["missionary", "child_rescuer", "author", "social_reformer"],
    "achievements": [
      "Rescued over 1,000 children from temple prostitution",
      "Founded Dohnavur Fellowship still operating today",
      "Exposed the hidden practice of temple child prostitution",
      "Authored 35 influential Christian books",
      "Served in India for 56 years without returning home"
    ],
    "quiz": [
      {
        "question": "What practice did Amy Carmichael expose and fight against in India?",
        "options": [
          "Child marriage",
          "Temple child prostitution",
          "Widow burning (sati)",
          "Caste discrimination"
        ],
        "correct": 1,
        "explanation": "Amy Carmichael discovered and courageously fought against the practice of dedicating young children, especially girls, to temples for religious prostitution. This was a hidden evil that she exposed despite fierce opposition from religious authorities."
      },
      {
        "question": "How many years did Amy serve in India without returning home?",
        "options": [
          "40 years",
          "50 years", 
          "56 years",
          "60 years"
        ],
        "correct": 2,
        "explanation": "Amy Carmichael served in India for 56 continuous years from 1895 to 1951 without ever taking a furlough home to Ireland. This demonstrated her complete dedication to the children and people she served."
      }
    ],
    "source": "wikimedia",
    "sourceUrl": "https://en.wikipedia.org/wiki/Amy_Carmichael",
    "attribution": "Based on Wikipedia and historical sources",
    "lastModified": "2025-01-27T22:00:00Z",
    "lang": "en"
  },
  // New Enhanced Profiles
  {
    "id": "ida-scudder",
    "name": "Ida Sophia Scudder",
    "displayName": "Dr. Ida Scudder - Pioneer of Women's Medical Education in India",
    "dates": {
      "birth": 1870,
      "death": 1960,
      "display": "1870-1960"
    },
    "image": "https://upload.wikimedia.org/wikipedia/commons/6/6d/Ida_S._Scudder_1899.jpg",
    "images": [
      "https://upload.wikimedia.org/wikipedia/commons/6/6d/Ida_S._Scudder_1899.jpg"
    ],
    "summary": "American missionary physician who founded the Christian Medical College & Hospital in Vellore, India, revolutionizing medical education for women in South India.",
    "biography": [
      {
        "title": "Early Life and Calling",
        "content": "Born in Ranipet, Tamil Nadu, India, to missionary parents, Ida initially resisted following in their footsteps. However, in 1894, she experienced her famous 'three knocks in the night' when three men came seeking medical help for their wives in childbirth. All three women died because no female doctor was available to treat them, as local customs forbade male doctors from attending to women. This profound experience became her divine calling to medicine."
      },
      {
        "title": "Medical Education and Return",
        "content": "Determined to address the critical need for women's healthcare, Ida enrolled at the Woman's Medical College of Pennsylvania in 1895, completing her final year at Cornell University Medical College in 1899 as part of the first class to accept women. She immediately returned to India to begin her medical ministry in Vellore, South India."
      },
      {
        "title": "Establishing Medical Infrastructure",
        "content": "Starting with a tiny dispensary in her father's bungalow, Ida treated 5,000 patients in her first two years. In 1902, she established the Mary Taber Schell Hospital, a 40-bed facility for women. She also pioneered 'roadside clinics' that brought medical care directly to rural villages, revolutionizing healthcare delivery in remote areas."
      },
      {
        "title": "Educational Pioneer",
        "content": "In 1918, Ida founded the Christian Medical College & Hospital, establishing the first medical school in India exclusively for women. The school received 151 applications in its first year, demonstrating the tremendous need. In 1928, Mahatma Gandhi visited the medical school, recognizing its significant contribution to India's development."
      },
      {
        "title": "Legacy and Recognition",
        "content": "Under Ida's leadership, the institution grew into one of India's premier medical colleges. In 1945, the college opened its doors to men as well. By 2003, the Vellore Christian Medical Center had become the largest Christian hospital in the world with 2,000 beds. In 2023, it was ranked the third-best medical college in India by the National Institute Ranking Framework."
      }
    ],
    "timeline": [
      {
        "year": 1870,
        "title": "Birth in India",
        "description": "Born in Ranipet, Tamil Nadu, to American missionary parents Dr. John Scudder Jr. and Sophia Weld Scudder.",
        "type": "birth",
        "significance": "Born into a family of medical missionaries but initially resisted the calling."
      },
      {
        "year": 1894,
        "title": "The Three Knocks",
        "description": "Experienced her famous calling when three women died in childbirth due to lack of female medical care.",
        "type": "calling",
        "significance": "The pivotal moment that led her to pursue medical education and dedicate her life to women's healthcare in India."
      },
      {
        "year": 1899,
        "title": "Medical Graduation",
        "description": "Graduated from Cornell University Medical College, New York, as part of the first class to accept women.",
        "type": "education",
        "significance": "Prepared her for medical ministry with the best training available to women at the time."
      },
      {
        "year": 1902,
        "title": "Schell Hospital Founded",
        "description": "Established the Mary Taber Schell Hospital, a 40-bed facility for women in Vellore.",
        "type": "ministry",
        "significance": "First permanent medical facility addressing women's healthcare needs in the region."
      },
      {
        "year": 1918,
        "title": "Medical College Established",
        "description": "Founded the Christian Medical College & Hospital, India's first medical school for women.",
        "type": "education",
        "significance": "Revolutionized medical education in India by training Indian women as doctors and nurses."
      },
      {
        "year": 1928,
        "title": "Gandhi's Visit",
        "description": "Mahatma Gandhi visited the medical school, acknowledging its contribution to India's progress.",
        "type": "recognition",
        "significance": "National recognition of the institution's importance in India's development."
      },
      {
        "year": 1945,
        "title": "Co-educational Expansion",
        "description": "The medical college opened its doors to male students, expanding its impact.",
        "type": "expansion",
        "significance": "Doubled the institution's capacity to train medical professionals for India."
      },
      {
        "year": 1960,
        "title": "Death and Legacy",
        "description": "Died in Vellore at age 89, leaving behind a medical institution serving millions.",
        "type": "death",
        "significance": "Her work established a lasting institution that continues to serve India's healthcare needs."
      }
    ],
    "locations": [
      {
        "name": "Vellore, Tamil Nadu",
        "coordinates": [12.9165, 79.1325],
        "type": "primary_ministry",
        "description": "Location of her life's work - the Christian Medical College & Hospital.",
        "years": "1900-1960",
        "significance": "Became the center of medical education and women's healthcare in South India."
      },
      {
        "name": "Ranipet, Tamil Nadu",
        "coordinates": [12.9342, 79.3370],
        "type": "birthplace",
        "description": "Birthplace where she was born to missionary parents.",
        "years": "1870",
        "significance": "Shaped her early understanding of missionary work and India's needs."
      }
    ],
    "categories": ["missionary", "physician", "educator", "women's rights"],
    "achievements": [
      "Founded India's first medical college for women",
      "Pioneered rural healthcare delivery through roadside clinics",
      "Trained thousands of Indian women as doctors and nurses",
      "Established one of the world's largest Christian hospitals"
    ],
    "quiz": [
      {
        "question": "What was the 'three knocks in the night' that called Ida Scudder to medicine?",
        "options": [
          "Three dreams she had about becoming a doctor",
          "Three women who died in childbirth because no female doctor was available",
          "Three patients who knocked on her door for help",
          "Three letters she received asking for medical help"
        ],
        "correct": 1,
        "explanation": "The 'three knocks' refers to three separate occasions in one night when men came seeking medical help for their wives in childbirth. All three women died because cultural customs prevented male doctors from attending to them, and no female doctor was available."
      },
      {
        "question": "What made Ida Scudder's medical college unique when it was founded in 1918?",
        "options": [
          "It was the first medical college in India",
          "It was exclusively for women students",
          "It offered free education to all students",
          "It was the largest medical college in Asia"
        ],
        "correct": 1,
        "explanation": "The Christian Medical College was India's first medical school exclusively for women, addressing the critical need for female healthcare providers in a society where women could not be treated by male doctors."
      }
    ],
    "source": "wikimedia",
    "sourceUrl": "https://en.wikipedia.org/wiki/Ida_S._Scudder",
    "attribution": "Based on Wikipedia and historical sources",
    "lastModified": "2025-01-27T22:00:00Z",
    "lang": "en"
  },
  {
    "id": "alexander-duff",
    "name": "Alexander Duff",
    "displayName": "Alexander Duff - Pioneer of English Christian Education in India",
    "dates": {
      "birth": 1806,
      "death": 1878,
      "display": "1806-1878"
    },
    "image": "https://upload.wikimedia.org/wikipedia/en/4/44/Alexduff.jpeg",
    "images": [
      "https://upload.wikimedia.org/wikipedia/en/4/44/Alexduff.jpeg"
    ],
    "summary": "Scottish missionary and educator who revolutionized Christian education in India by introducing English-language instruction and establishing the foundation for modern higher education in Bengal.",
    "biography": [
      {
        "title": "Early Life and Calling",
        "content": "Born on April 25, 1806, in Moulin, Perthshire, Scotland, to a farming family, Alexander Duff excelled in his studies at the University of St. Andrews. Influenced by Professor Thomas Chalmers, he felt called to missionary service and became the first official missionary of the Church of Scotland to India in 1829."
      },
      {
        "title": "Arrival and Educational Innovation",
        "content": "After surviving two shipwrecks during his voyage, Duff arrived in Calcutta on May 27, 1830. Recognizing that traditional missionary approaches had limited success with upper-caste Hindus, he pioneered a revolutionary strategy: offering quality English education combined with Christian instruction. This approach attracted the Bengali elite who desired Western education for their children."
      },
      {
        "title": "Founding Educational Institutions",
        "content": "On July 13, 1830, Duff founded the General Assembly's Institution (now Scottish Church College) in Calcutta. His educational model emphasized teaching through English rather than local languages, covering a broad curriculum including sciences, literature, and Christian theology. This approach proved so successful that it became the template for missionary education across India."
      },
      {
        "title": "University Development",
        "content": "Duff played a crucial role in establishing the University of Calcutta, drawing up its constitution and insisting on the inclusion of physical sciences in the curriculum. He was the first to advocate for comprehensive scientific education in Indian universities, believing that all knowledge, properly understood, led to God."
      },
      {
        "title": "Lasting Impact on Indian Education",
        "content": "Through his three periods of service in India (1830-1834, 1840-1851, 1855-1863), Duff established a educational philosophy that influenced generations. His emphasis on English-language higher education became the standard for missionary institutions and significantly influenced the development of modern Indian education system."
      }
    ],
    "timeline": [
      {
        "year": 1806,
        "title": "Birth in Scotland",
        "description": "Born in Moulin, Perthshire, Scotland, to James Duff, a farmer and gardener.",
        "type": "birth",
        "significance": "Grew up in a devout Christian farming family that valued education and faith."
      },
      {
        "year": 1824,
        "title": "University Graduation",
        "description": "Graduated with M.A. (Hons) from University of St. Andrews after only two years.",
        "type": "education",
        "significance": "Demonstrated exceptional academic ability that would serve him in his educational mission."
      },
      {
        "year": 1829,
        "title": "Missionary Ordination",
        "description": "Ordained as the first official missionary of the Church of Scotland to India.",
        "type": "calling",
        "significance": "Marked the beginning of a systematic Scottish missionary effort in India."
      },
      {
        "year": 1830,
        "title": "Arrival in Calcutta",
        "description": "Arrived in Calcutta after surviving two shipwrecks during his voyage to India.",
        "type": "arrival",
        "significance": "The dramatic journey demonstrated his commitment to his calling despite severe obstacles."
      },
      {
        "year": 1830,
        "title": "Educational Institution Founded",
        "description": "Founded the General Assembly's Institution (now Scottish Church College) in Calcutta.",
        "type": "ministry",
        "significance": "Revolutionary approach of combining English education with Christian instruction."
      },
      {
        "year": 1843,
        "title": "Church Disruption",
        "description": "Joined the Free Church of Scotland during the Disruption, maintaining his missionary work.",
        "type": "church",
        "significance": "Chose principle over security, aligning with the Free Church movement."
      },
      {
        "year": 1851,
        "title": "First Moderatorship",
        "description": "Elected Moderator of the Free Church of Scotland General Assembly for the first time.",
        "type": "recognition",
        "significance": "Recognition of his contributions to both missions and church leadership."
      },
      {
        "year": 1878,
        "title": "Death and Legacy",
        "description": "Died in Sidmouth, Devon, leaving behind a transformed educational landscape in India.",
        "type": "death",
        "significance": "His educational philosophy continued to influence Indian higher education for generations."
      }
    ],
    "locations": [
      {
        "name": "Calcutta (Kolkata), West Bengal",
        "coordinates": [22.5726, 88.3639],
        "type": "primary_ministry",
        "description": "Center of his educational mission and home to his pioneering institution.",
        "years": "1830-1863",
        "significance": "Became the model for English Christian education across British India."
      },
      {
        "name": "Moulin, Perthshire, Scotland",
        "coordinates": [56.7023, -3.7398],
        "type": "birthplace",
        "description": "Rural Scottish village where he was born and raised.",
        "years": "1806-1824",
        "significance": "Shaped his character with Scottish Presbyterian values and love of learning."
      }
    ],
    "categories": ["missionary", "educator", "theologian", "reformer"],
    "achievements": [
      "First official missionary of Church of Scotland to India",
      "Pioneered English-language Christian education in India",
      "Founded Scottish Church College, Calcutta",
      "Helped establish University of Calcutta",
      "Served twice as Moderator of Free Church of Scotland"
    ],
    "quiz": [
      {
        "question": "What was Alexander Duff's revolutionary approach to missionary work in India?",
        "options": [
          "Learning all local languages and customs",
          "Providing English education combined with Christian instruction",
          "Establishing hospitals and medical clinics",
          "Converting lower-caste people first"
        ],
        "correct": 1,
        "explanation": "Duff recognized that offering quality English education would attract upper-caste Hindus who desired Western education for their children, creating opportunities to share Christian teaching with influential members of society."
      },
      {
        "question": "What happened to Alexander Duff during his journey to India?",
        "options": [
          "He was delayed by storms for three months",
          "He was attacked by pirates",
          "He survived two shipwrecks",
          "He became seriously ill with tropical fever"
        ],
        "correct": 2,
        "explanation": "During his voyage to India in 1829-1830, Duff's ship was wrecked twice, but he persevered and finally reached Calcutta, seeing these trials as confirmation of his calling."
      }
    ],
    "source": "wikimedia",
    "sourceUrl": "https://en.wikipedia.org/wiki/Alexander_Duff_(missionary)",
    "attribution": "Based on Wikipedia and historical sources",
    "lastModified": "2025-01-27T22:00:00Z",
    "lang": "en"
  },
  {
    "id": "pandita-ramabai",
    "name": "Pandita Ramabai Sarasvati",
    "displayName": "Pandita Ramabai - Pioneer of Women's Education and Rights in India",
    "dates": {
      "birth": 1858,
      "death": 1922,
      "display": "1858-1922"
    },
    "image": "https://upload.wikimedia.org/wikipedia/commons/a/a1/Pandita_Ramabai_Sarasvati_1858-1922_front-page-portrait.jpg",
    "images": [
      "https://upload.wikimedia.org/wikipedia/commons/a/a1/Pandita_Ramabai_Sarasvati_1858-1922_front-page-portrait.jpg"
    ],
    "summary": "Indian social reformer, scholar, and Christian convert who championed women's education and rights, founded institutions for widows and orphans, and translated the Bible into Marathi.",
    "biography": [
      {
        "title": "Early Life and Scholarly Recognition",
        "content": "Born into a high-caste Chitpavan Brahmin family in Karnataka, Ramabai received an unusual education in Sanskrit from her father Anant Shastri Dongre, who believed in women's education. Orphaned at 16 during the Great Famine of 1876-78, she traveled with her brother reciting Sanskrit scriptures. Her exceptional knowledge earned her the rare titles of 'Pandita' and 'Sarasvati' from Calcutta University in 1878."
      },
      {
        "title": "Marriage and Social Reform Beginnings",
        "content": "Breaking social conventions, Ramabai married Bengali lawyer Bipin Behari Medhvi in 1880 in a civil ceremony that crossed caste lines. Widowed after just two years when her husband died of cholera, she emerged as an independent woman and single mother, founding the Arya Mahila Samaj (Arya Women's Society) in Pune to educate women and combat child marriage."
      },
      {
        "title": "Christian Conversion and International Advocacy",
        "content": "In 1883, while in England, Ramabai converted to Christianity after intensive Bible study, finding in Jesus her 'best Liberator.' She toured the United States extensively, raising funds for destitute Indian women and publishing 'The High Caste Hindu Woman' (1887), considered India's first feminist manifesto, which exposed the suffering of Indian women."
      },
      {
        "title": "Founding Educational Institutions",
        "content": "In 1889, Ramabai established Sharada Sadan (Home for Learning) in Mumbai for young Hindu widows, providing education and security. She later moved the institution to Kedgaon, renaming it Mukti Mission. During the 1896 famine, she rescued thousands of outcast children, child widows, and destitute women, expanding her mission significantly."
      },
      {
        "title": "Biblical Translation and Legacy",
        "content": "A polyglot knowing seven languages, Ramabai undertook the monumental task of translating the Bible into Marathi directly from Hebrew and Greek texts, completing this work in 1924. She received the Kaiser-i-Hind Medal in 1919 for her social service and continued working until her death in 1922, leaving behind institutions that continue to serve thousands."
      }
    ],
    "timeline": [
      {
        "year": 1858,
        "title": "Birth in Karnataka",
        "description": "Born as Ramabai Dongre into a Chitpavan Brahmin family in Karnataka.",
        "type": "birth",
        "significance": "Born into privilege but would dedicate her life to helping India's most marginalized women."
      },
      {
        "year": 1876,
        "title": "Orphaned in Famine",
        "description": "Parents died during the Great Famine of 1876-78, leaving her and her brother to fend for themselves.",
        "type": "tragedy",
        "significance": "Early experience of hardship shaped her empathy for suffering women."
      },
      {
        "year": 1878,
        "title": "Scholarly Recognition",
        "description": "Received the titles 'Pandita' and 'Sarasvati' from Calcutta University for Sanskrit scholarship.",
        "type": "recognition",
        "significance": "Rare honor for a woman, establishing her intellectual credentials."
      },
      {
        "year": 1880,
        "title": "Revolutionary Marriage",
        "description": "Married Bengali lawyer Bipin Behari Medhvi in a civil ceremony crossing caste lines.",
        "type": "personal",
        "significance": "Challenged orthodox Hindu marriage customs, asserting women's right to choose."
      },
      {
        "year": 1883,
        "title": "Christian Conversion",
        "description": "Converted to Christianity in England after intensive study of the Bible.",
        "type": "spiritual",
        "significance": "Found in Christianity the liberation and equality she sought for women."
      },
      {
        "year": 1889,
        "title": "Educational Institution Founded",
        "description": "Established Sharada Sadan (Home for Learning) in Mumbai for Hindu widows.",
        "type": "ministry",
        "significance": "First institution specifically for educating and empowering young widows."
      },
      {
        "year": 1896,
        "title": "Famine Relief Work",
        "description": "Rescued thousands of destitute women and children during severe famine in Maharashtra.",
        "type": "service",
        "significance": "Demonstrated practical Christian compassion on massive scale."
      },
      {
        "year": 1922,
        "title": "Death and Continuing Legacy",
        "description": "Died at age 64, leaving behind thriving institutions serving thousands of women.",
        "type": "death",
        "significance": "Her Mukti Mission continues operating today, testimony to her lasting impact."
      }
    ],
    "locations": [
      {
        "name": "Kedgaon, Maharashtra",
        "coordinates": [18.6707, 74.1553],
        "type": "primary_ministry",
        "description": "Location of her Mukti Mission, serving thousands of women and children.",
        "years": "1896-1922",
        "significance": "Became a haven for India's most marginalized women and children."
      },
      {
        "name": "Mumbai, Maharashtra",
        "coordinates": [19.0760, 72.8777],
        "type": "educational_work",
        "description": "Site of her first institution, Sharada Sadan.",
        "years": "1889-1896",
        "significance": "Pioneered women's education and widow rehabilitation in urban India."
      }
    ],
    "categories": ["social_reformer", "educator", "translator", "women's_rights", "christian_convert"],
    "achievements": [
      "First woman to receive 'Pandita' title from Calcutta University",
      "Authored India's first feminist manifesto",
      "Founded institutions serving thousands of destitute women",
      "Translated the Bible into Marathi from original languages",
      "Pioneered widow rehabilitation and women's education"
    ],
    "quiz": [
      {
        "question": "What rare honor did Pandita Ramabai receive from Calcutta University in 1878?",
        "options": [
          "The first honorary doctorate given to a woman",
          "The titles 'Pandita' and 'Sarasvati' for Sanskrit scholarship",
          "Appointment as the first female professor",
          "Recognition as the greatest woman scholar of India"
        ],
        "correct": 1,
        "explanation": "Calcutta University conferred the prestigious titles 'Pandita' (learned one) and 'Sarasvati' (goddess of learning) on Ramabai in recognition of her exceptional knowledge of Sanskrit scriptures, a rare honor for any woman in that era."
      },
      {
        "question": "What was groundbreaking about 'The High Caste Hindu Woman' published in 1887?",
        "options": [
          "It was the first book written by an Indian woman in English",
          "It was India's first feminist manifesto exposing women's suffering",
          "It was the first Sanskrit text translated by a woman",
          "It was the first book advocating for Indian independence"
        ],
        "correct": 1,
        "explanation": "The book was considered India's first feminist manifesto, providing a comprehensive and shocking expose of the suffering endured by Indian women, particularly high-caste Hindu women, and launching international awareness of their plight."
      }
    ],
    "source": "wikimedia",
    "sourceUrl": "https://en.wikipedia.org/wiki/Pandita_Ramabai",
    "attribution": "Based on Wikipedia and historical sources",
    "lastModified": "2025-01-27T22:00:00Z",
    "lang": "en"
  }
];

// Utility functions
function getMissionaryById(id) {
  return MISSIONARY_PROFILES.find(profile => profile.id === id);
}

function getProfileSummaries(profiles) {
  return profiles.map(profile => ({
    id: profile.id,
    name: profile.name,
    displayName: profile.displayName,
    dates: profile.dates,
    image: profile.image,
    summary: profile.summary,
    categories: profile.categories
  }));
}

function filterProfiles(profiles, category) {
  if (!category || category === 'all') {
    return profiles;
  }
  return profiles.filter(profile => 
    profile.categories.some(cat => 
      cat.toLowerCase().includes(category.toLowerCase())
    )
  );
}

function searchProfiles(profiles, query) {
  const searchTerm = query.toLowerCase();
  return profiles.filter(profile => 
    profile.name.toLowerCase().includes(searchTerm) ||
    profile.displayName.toLowerCase().includes(searchTerm) ||
    profile.summary.toLowerCase().includes(searchTerm) ||
    profile.categories.some(cat => cat.toLowerCase().includes(searchTerm)) ||
    profile.biography.some(section => 
      section.title.toLowerCase().includes(searchTerm) ||
      section.content.toLowerCase().includes(searchTerm)
    )
  );
}

// Main API Handler
export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const path = url.pathname;

    // Handle CORS
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Content-Type': 'application/json'
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    try {
      // Health check endpoint
      if (path === '/health') {
        return new Response(JSON.stringify({
          status: 'healthy',
          timestamp: new Date().toISOString(),
          version: '2.0.0',
          profiles_count: MISSIONARY_PROFILES.length,
          endpoints: [
            '/health',
            '/api/profiles',
            '/api/profile/{id}',
            '/api/search/{query}'
          ]
        }), { 
          headers: corsHeaders,
          status: 200
        });
      }

      // Get all profiles with pagination
      if (path === '/api/profiles') {
        const limit = parseInt(url.searchParams.get('limit')) || 20;
        const offset = parseInt(url.searchParams.get('offset')) || 0;
        const category = url.searchParams.get('category') || 'all';

        let filteredProfiles = filterProfiles(MISSIONARY_PROFILES, category);
        const total = filteredProfiles.length;
        
        const paginatedProfiles = filteredProfiles.slice(offset, offset + limit);
        const profileSummaries = getProfileSummaries(paginatedProfiles);

        return new Response(JSON.stringify({
          profiles: profileSummaries,
          pagination: {
            limit,
            offset,
            total,
            hasMore: offset + limit < total
          },
          category
        }), {
          headers: corsHeaders,
          status: 200
        });
      }

      // Get single profile by ID
      if (path.startsWith('/api/profile/')) {
        const profileId = path.split('/')[3];
        const profile = getMissionaryById(profileId);

        if (!profile) {
          return new Response(JSON.stringify({
            error: 'Profile not found',
            message: `No missionary profile found with ID: ${profileId}`,
            available_ids: MISSIONARY_PROFILES.map(p => p.id)
          }), {
            headers: corsHeaders,
            status: 404
          });
        }

        return new Response(JSON.stringify(profile), {
          headers: corsHeaders,
          status: 200
        });
      }

      // Search profiles
      if (path.startsWith('/api/search/')) {
        const query = decodeURIComponent(path.split('/')[3]);
        const limit = parseInt(url.searchParams.get('limit')) || 10;
        
        const searchResults = searchProfiles(MISSIONARY_PROFILES, query);
        const limitedResults = searchResults.slice(0, limit);
        const profileSummaries = getProfileSummaries(limitedResults);

        return new Response(JSON.stringify({
          query,
          results: profileSummaries,
          total_results: searchResults.length,
          showing: limitedResults.length
        }), {
          headers: corsHeaders,
          status: 200
        });
      }

      // 404 for unknown endpoints
      return new Response(JSON.stringify({
        error: 'Endpoint not found',
        message: `The requested endpoint ${path} was not found`,
        available_endpoints: [
          '/health',
          '/api/profiles',
          '/api/profile/{id}',
          '/api/search/{query}'
        ]
      }), {
        headers: corsHeaders,
        status: 404
      });

    } catch (error) {
      console.error('API Error:', error);
      return new Response(JSON.stringify({
        error: 'Internal server error',
        message: error.message,
        timestamp: new Date().toISOString()
      }), {
        headers: corsHeaders,
        status: 500
      });
    }
  }
};