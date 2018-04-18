# Rotate
A ruby app that 'rotates' my Rocket League clips from my xbox profile to my gfycat profile.

_**Rotate**: When the team moves in between positions, from defense to offense._

## Usage

```
http://localhost:4567/auth-gfycat
```

* Authenticates with gyfcat to access the API.

```
http://localhost:4567/scrape?days_ago=3
```

* Scrapes http://xboxdvr.com/ for my clips that were posted within the days specified and uploads those clips to my gfycat profile. 

* In this example, I'm scraping the xbox clips that were recorded within 3 days. 

* `days_ago` will default to 10 days if not specified.
