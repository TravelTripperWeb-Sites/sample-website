# Sample Website
## Introduction
This README describes how to create a Jekyll website integrated with [TravelTripper CMS](www.traveltripper.io).

CMS's website can be developed locally using a number of plugins. These plugins add CMS integration and some usefull features (see below).

## Starting local development

To CMS website's development the following is needed: 

* Ruby and Gem
* Bundler: `gem install bundler`
* Required gems are listed in Gemfile.dev file, copy it inside your local development folder: `cp Gemfile.dev Gemfile`
* and install dependencies: `bundle install`

## Project structure

To create an empty project:

* copy `_plugins` folder from the [repository](_plugins)
* create default layout file: `_layouts/default.html`

```
<html>
    <head>
        <title> {{ page.title }} </title>
    </head>
    <body>
    {{ content }}
    </body>
</html>
```
* create `index.html` page

```
---
layout: default
title: Page Title
---
Index page content
```

Run `jekyll serve` to view the result in your browser.

This project supports many CMS's extentions but doesn't use it.  

## i18n
To localize a website additional configuration is needed. Create `_config.yml` file as following:
```
default_lang: 'en'
languages: ['en', 'ru']
```

This will copy website's pages of additional languages to a locale sub-folder. A default language copy is stored 
under the project root. So, after this update, we can see `index.html` and `ru/index.html` pages, however their 
content is the same.

## Translation tags
To add localized content (e.g. labels, captions, etc) translation keys should be used.

Create `_locales` folder and `<language>.yml` files in [i18n format](http://guides.rubyonrails.org/i18n.html). 
In dynamic pages (which contain [Front Matter](http://jekyllrb.com/docs/frontmatter/)) `t` tag can be used.

For example, create `en.yml` file:
```
en:
  hello: 'EN hello label'
```
**Locale YAML file must be created for every specified language and at least one translation is needed**. 
Other translation keys can be skipped, 
in this case error message is shown: `translation missing: <locale>.<key>` as a result of `t` tag rendering.

Update `index.html` using `translate` tag:

```
---
layout: default
title: Page Title
---
<h5>{% t hello %}</h5>
Index page content
<p>{% t signature %}</p>
```
As a result '/index.html' will show:
> ####EN hello label
>
> Index page content
>
> translation missing: en.signature

A russian translation of the page will show all keys as missed.

## Localizable properties

Page's Front Matter can contain different variables which might be rendered via Liquid code: `{{ page.variable_name }}`.
For example: `page.title` is used in the `default.html` layout file. It can be localized using the following syntax:

```
---
  title_localized:
    en: EN Page Title
    ru: RU Page Title
  layout: default
---
...
```
The reference to title's value will use current language, so EN and RU pages will have translated titles accordingly.

## References to a page's translation
**WIP**

## Editable Regions

The plugins allow to define a region which is editable via CMS. 
Every region can contain different region items. Each item is loaded from a data file and rendered using a particular template (which is referenced to from the item's data). Regions are unique for their hosting page and each language. 

A liquid tag "region" requires one constant parameter which defines region's name. Add the next rows to `index.html`:
```
{% region region1 %}
```
To edit region's content manually create `_data/_regions/en/index.html/region1.json` as follows:
```
[
    {
        "_template": "html",
        "content": "<p>1st item</p>"
    },
    {
        "_template": "html",
        "content": "<p>2nd item</p>"
    }
]
```
Rendered page includes:

> 1st item
> 2nd item

Translated version of the page won't show any region's content since we didn't create it.

Regions' data is stored in the folder named `_data/_regions/<language>/<page_path>/<region_name>.json` folder. File can be created by the CMS when a user edits region's content. If the is created by programmer it must be a valid JSON file, including array of region's items. Every item should include `_template` and `content` property.

Region item's template is used to render the data. `html` template is buit-in, however others template can be created or the `html` template can be overwritten. Create `_data/_includes/_regions/html` file:
```
Custom HTML template: {{include.instance.content}}
```

After the update the result it:
> Custom HTML template:
> 1st item
>
> Custom HTML template:
> 2nd item

`include.instance` is a reference to rendered region item, so any additional fields can be used both in the Region item and its template. The CMS allows users to edit HTML region items, a possibility to create new editors will be added later.

### Includes and Editable Regions

## Data Pages
**TBD**

## Data References
**TBD**
