# Static Shock

[![Build Status](https://app.bitrise.io/app/39cebc0c-2d0d-40e7-bc10-0923acca938d/status.svg?token=WYyIN_s_GWqZf2TtRrKJTA&branch=main)](https://app.bitrise.io/app/39cebc0c-2d0d-40e7-bc10-0923acca938d)

a static site generator written in swift

## usage

`$ staticshock folder`

### project structure

```
.
| index.md
| any html or markdown files
| post.html template
| header.html template
| footer.html template
|
|__ posts
|   | markdown files
|
|__ css
|   | css files
|
|__ js
    | js files     
```

## installation

### build from source

`$ git clone https://github.com/matty316/staticShock.git`

`$ cd staticShock`

`$ swift build -c release`

`$ cd .build/release`

`$ sudo cp -f StaticShock /usr/local/bin/staticshock`
