--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

-- Lua table of addresses for the address book
-- These entries may be added or deleted by the Lua code
gAddressBook = {
	{
		first_name = "Tyrion",
		last_name = "Lannister",
		address = "Casterly Rock",
		email = "Tyrion@Lannister.net",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Tyrion.png",
		fav = 0
	},
	{
		first_name = "Jaime",
		last_name = "Lannister",
		address = "Casterly Rock",
		email = "Jaime@Lannister.net",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Kingsguard_icon.jpg",
		fav = 0
	},
	{
		first_name = "Cersei",
		last_name = "Lannister",
		address = "Casterly Rock",
		email = "Cersei@Lannister.net",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Cersei_Lannister.png",
		fav = 0
	},
	{
		first_name = "Daenerys",
		last_name = "Targaryen",
		address = "Dragon Stone",
		email = "Daenerys@Targaryen.net",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Daenerys_S3.jpg",
		fav = 0
	},
	{
		first_name = "Jon",
		last_name = "Snow",
		address = "Winterfell",
		email = "Jon@Winterfell-online.com",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Jon-Snow-S3.jpg",
		fav = 0
	},
	{
		first_name = "Jorah",
		last_name = "Mormont",
		address = "Bear Island",
		email = "Jorah@Mormont.net",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Jorah.jpg",
		fav = 0
	},
	{
		first_name = "Petyr",
		last_name = "Baelish",
		address = "The Fingers",
		email = "Petyr@the-fingers.com",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/PetyrBaelish.jpg",
		fav = 0
	},
	{
		first_name = "Tywin",
		last_name = "Lannister",
		address = "Castle Rock",
		email = "Tywin@Lannister.net",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Tywin_lannister.jpg",
		fav = 0
	},
	{
		first_name = "Davos",
		last_name = "Seaworth",
		address = "Kings Landing",
		email = "Davos@TheOnion.net",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Davos.png",
		fav = 0
	},
	{
		first_name = "Stannis",
		last_name = "Baratheon",
		address = "Storm's End",
		email = "Stannis@firegod.com",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Stannis.jpg",
		fav = 0
	},	
	{
		first_name = "Margaery",
		last_name = "Tyrell",
		address = "Highgarden",
		email = "Margaery@TyrellNetworks.com",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Margaery.png",
		fav = 0
	},	
	{
		first_name = "Bran",
		last_name = "Stark",
		address = "Winterfell",
		email = "Bran@Weirwood.net",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Bran.png",
		fav = 0
	},	
	{
		first_name = "Sansa",
		last_name = "Stark",
		address = "King's Landing",
		email = "Sansa@Winterfell-online.com",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/sansa.jpg",
		fav = 0
	},	
	{
		first_name = "Arya",
		last_name = "Stark",
		address = "Winterfell",
		email = "Arya@Winterfell-online.com",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/arya.png",
		fav = 0
	},	
	{
		first_name = "Theon",
		last_name = "Greyjoy",
		address = "Winterfell",
		email = "Theon@Winterfell-online.com",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Theon_S3.jpg",
		fav = 0
	},	
	{
		first_name = "Joffrey",
		last_name = "Baratheon",
		address = "King's Landing",
		email = "Joffrey@TheKingsInternet.com",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Joff.jpg",
		fav = 0
	},	
	{
		first_name = "Samwell",
		last_name = "Tarly",
		address = "Horn Hill",
		email = "Joffrey@NightsWatch.com",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Samwell.jpg",
		fav = 0
	},	
	{
		first_name = "Rob",
		last_name = "Stark",
		address = "Winterfell",
		email = "Rob@Winterfell-online.com",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Robb-Stark.jpg",
		fav = 0
	},	
	{
		first_name = "Catelyn",
		last_name = "Stark",
		address = "Winterfell",
		email = "Catelyn@Winterfell-online.com",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Catelyn_Stark.jpg",
		fav = 0
	},	
	{
		first_name = "Eddard",
		last_name = "Stark",
		address = "Winterfell",
		email = "Eddard@Winterfell-online.com",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/EddardStark.jpg",
		fav = 0
	},	
	{
		first_name = "Khal",
		last_name = "Drogo",
		address = "Vaes Dothrak",
		email = "Drogo@Horse.com",
		office = "613-595-1999 ext 0",
		mobile = "555-212-4567",
		home = "555-393-9001",
		image = "images/head_shots/Drogo.jpg",
		fav = 0
	}
}
