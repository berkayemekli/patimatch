class PetTaxonomy {
  static const List<String> animalCategories = <String>[
    'Kopek',
    'Kedi',
  ];

  static const List<String> turkiyeSehirleri = <String>[
    'Adana','Adiyaman','Afyonkarahisar','Agri','Amasya','Ankara','Antalya','Artvin','Aydin','Balikesir','Bilecik','Bingol','Bitlis','Bolu','Burdur','Bursa','Canakkale','Cankiri','Corum','Denizli','Diyarbakir','Edirne','Elazig','Erzincan','Erzurum','Eskisehir','Gaziantep','Giresun','Gumushane','Hakkari','Hatay','Isparta','Mersin','Istanbul','Izmir','Kars','Kastamonu','Kayseri','Kirklareli','Kirsehir','Kocaeli','Konya','Kutahya','Malatya','Manisa','Kahramanmaras','Mardin','Mugla','Mus','Nevsehir','Nigde','Ordu','Rize','Sakarya','Samsun','Siirt','Sinop','Sivas','Tekirdag','Tokat','Trabzon','Tunceli','Sanliurfa','Usak','Van','Yozgat','Zonguldak','Aksaray','Bayburt','Karaman','Kirikkale','Batman','Sirnak','Bartin','Ardahan','Igdir','Yalova','Karabuk','Kilis','Osmaniye','Duzce'
  ];

  static const List<String> kopekIrklari = <String>[
    'Kirma', 'Golden Retriever', 'Labrador Retriever', 'German Shepherd', 'Kangal', 'Akbash', 'Poodle', 'French Bulldog', 'Siberian Husky', 'Border Collie', 'Beagle', 'Cocker Spaniel', 'Rottweiler', 'Doberman', 'Pug', 'Shih Tzu', 'Chihuahua', 'Maltese', 'Pomeranian', 'Cane Corso', 'American Staffordshire Terrier', 'Jack Russell Terrier', 'Samoyed', 'Dachshund', 'Boxer'
  ];

  static const List<String> kediIrklari = <String>[
    'Kirma', 'Tekir', 'Van Kedisi', 'Ankara Kedisi', 'British Shorthair', 'Scottish Fold', 'Siamese', 'Persian', 'Maine Coon', 'Bengal', 'Sphynx', 'Ragdoll', 'Russian Blue', 'Norwegian Forest Cat', 'Abyssinian'
  ];

  static const Map<String, List<String>> ilceMap = <String, List<String>>{
    'Istanbul': <String>['Adalar','Arnavutkoy','Atasehir','Avcilar','Bagcilar','Bahcelievler','Bakirkoy','Basaksehir','Bayrampasa','Besiktas','Beykoz','Beylikduzu','Beyoglu','Buyukcekmece','Catalca','Cekmekoy','Esenler','Esenyurt','Eyupsultan','Fatih','Gaziosmanpasa','Gungoren','Kadikoy','Kagithane','Kartal','Kucukcekmece','Maltepe','Pendik','Sancaktepe','Sariyer','Silivri','Sisli','Sultanbeyli','Sultangazi','Tuzla','Umraniye','Uskudar','Zeytinburnu'],
    'Ankara': <String>['Altindag','Cankaya','Etimesgut','Golbasi','Kecioren','Mamak','Polatli','Pursaklar','Sincan','Yenimahalle'],
    'Izmir': <String>['Aliaga','Balcova','Bayrakli','Bornova','Buca','Cigli','Foca','Gaziemir','Guzelbahce','Karabaglar','Karaburun','Karsiyaka','Kemalpasa','Konak','Menderes','Menemen','Narlidere','Seferihisar','Selcuk','Tire','Torbali','Urla'],
    'Bursa': <String>['Gemlik','Gursu','Inegol','Iznik','Karacabey','Mudanya','Mustafakemalpasa','Nilufer','Orhangazi','Osmangazi','Yildirim'],
    'Antalya': <String>['Aksu','Alanya','Dosemealti','Finike','Gazipasa','Kas','Kepez','Konyaalti','Kumluca','Manavgat','Muratpasa','Serik'],
    'Kocaeli': <String>['Basiskele','Cayirova','Darica','Derince','Dilovasi','Gebze','Golcuk','Izmit','Kandira','Karamursel','Kartepe','Korfez'],
    'Mugla': <String>['Bodrum','Dalaman','Datca','Fethiye','Koycegiz','Marmaris','Milas','Ortaca','Seydikemer','Ula','Yatagan'],
    'Adana': <String>['Ceyhan','Cukurova','Imamoglu','Karaisali','Kozan','Saricam','Seyhan','Yumurtalik','Yuregir'],
  };
}
