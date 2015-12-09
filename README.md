# Basic Website Creation
Described example website is stored here: https://github.com/TravelTripperWeb/sample-website-tutorial

## Introduction
This README describes how to create a Jekyll-based website integrated with [TravelTripper CMS](www.traveltripper.io).

CMS's website can be developed locally using a number of plugins. These plugins add CMS integration and some usefull features which are described in this tutorial.

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

This project supports many CMS's extentions but doesn't use it yet.  

## i18n
To localize a website additional configuration is needed. Create `_config.yml` file as following:
```
default_lang: 'en'
languages: ['en', 'ru']
```

This will copy generated website's pages of additional languages to a locale sub-folder. A default language copy is stored 
under the project root. So, after this update, we can see `index.html` and `ru/index.html` pages, however their 
content is the same.

## Translation tags
To add localized content (e.g. labels, captions, etc) translation keys and files should be used.

Create `_locales` folder and `<language>.yml` files in [i18n format](http://guides.rubyonrails.org/i18n.html). 
In dynamic pages (which contain [Front Matter](http://jekyllrb.com/docs/frontmatter/)) `t` tag can be used.

For example, create `en.yml` file:
```
en:
  hello: 'EN hello label'
```
**Locale YAML file must be created for every specified language and at least one translation is needed**. 
Other translation keys can be skipped, 
in this case warning message is shown: `translation missing: <locale>.<key>` as a result of `t` tag rendering.

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

## Permalinks 
By default output file name is not changed when page is generated. Programmers and CMS's users can modify output URLs using `permalink` property in Front Matter section. This propery allows to rename a page's URL in different locales. For example, add localized permalink to `index.html`:
```
...
permalink_localized:
  ru: home
...
```

Missing english permalink translation will use `/index.html` filename, and russian version will be available at `/ru/home.html`.

## References to a page
To create a hyper link to another page `permalink` filter is created. The syntax for it is:
```
{{ <page|path> | permalink[: locale:<locale>] }}
```
Where:
* `page`: Liquid's object: represents a current rendering page.
* `path`: file's path, e.g. `/dir/file-name` for `/dir/file-name.html`
* `locale: <locale-value>`: a locale value/variable, to get a link to a particular translation. If locale is skipped then current locale is used.


There is additional syntax for Model-based pages:
```
{{ <model-file-name> | permalink: model-dir:<model-directory-name>[, locale:<locale>] }}
```
which is descrabed in the section below. 

## References to a page's translations

As it was said before to obtain a localized URL there is a simple synatax:
```
{{ page | permalink: locale: <language> }}
```

To iterate over languages the `site.languages` variable can be used, for example:
```
<p>Available languages:</p>
<ul>
    {% for lang in site.languages %}
        <li>{{ lang | upcase }}</li>
    {% endfor %}
</ul>
```

The code above returns:

> Available languages:
>
> * EN
> * RU

To handle current language there is `site.active_lang` variable. Liquid `if` tag allows highlighing current page's language.

The entire example of a language drop-down is shown below:

```
<select id="language" onchange="location = this.options[this.selectedIndex].value;">
  {% for lang in site.languages %}
    <option {% if lang == site.active_lang %} selected="true" {% endif%} value="{{ page | url: lang }}">
      {{ lang | upcase }}
    </option>
  {% endfor %}
</select>
```

## Editable Regions

The plugins allow to define a region which is editable via CMS. 
Every region can contain different region items. Each item is loaded from a data file and rendered using a particular template (which is referenced to from the item's data). Regions are unique for their hosting page and each language. 

A liquid tag `region` requires one constant parameter which defines region's name. Add the next rows to `index.html`:
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
Regions can be defined in include files. In this case region data is loaded for a target page. For example, create include file `_includes/reg_sample.html`. 
```
Included region: {% region region1 %}
```

Add liquid `include` tag into `index.html`: 
```
{% include reg_sample.html %}
```
As a result - the same `region1` block will be rendered twice on the page: firstly by the direct `region`, secondly through the included file.

## Data references
The plugins add auto references resolving to any Jekyll data. To activate it:
* store objects in a folder or file named as a plural noun, e.g. "groups/*.json" or "groups.json"
* add a numeric `id` field to a target referenced objects 
* add an association field to another object using a singular noun and `_id` postfix (e.g. "group_id")

**Only simple plural forms ending with 's' are supported by current version. For example, men/man_id reference will not be resolved.**

Objects reference will be autoloaded, so the following syntax works: `book.group.name`. 
The following example demonstrate this feature using single and multiple files to store data.

Create `_data/authors.json` to store an array of Authors:

```
[    
    {
        "id": 1,
        "name": "Jack London"
    }
]
```

Create `_data/groups` folder to store Groups as separate files:
> _data/groups/group1.json

```
{
  "id": 1,
  "name": "Group 1"
}
```

> _data/groups/group2.json

```
{
  "id": 2,
  "name": "Group 2"
}
```

Create `_data/books` folder to store Books objects as separate files. Each Book will refer to an Author and Group:

> _data/books/book1.json

```
{
  "author_id": 1,
  "group_id": 2,
  "title": "1st book",
  "description": "1st description"
}
```

> _data/books/book2.json

```
{
  "author_id": 1,
  "group_id": 1,
  "title": "2nd book",
  "description": "2nd description",
}
```
When rendered, every Book object has `author` and `group` properties, e.g. `{{ site.data.books['book1'].author.name }}`
and `{{ site.data.books['book1'].group.name }}`. The next topic explain how to iterate over that data to render it.

## Data iteration
This chapter explains standard Liquid approach to iterate over data arrays or hashes.

Liquid support  `for` cycle:
```
{% for variable in site.data.<data-object> %}
  {{ varibale.<property-name> }}
{% endfor %}
```
where "data-object" is a directory of file name (including path and excluding file extention). In case data object represents an array (e.g. CSV file, JSON array or YAML list) the declared variable is set to every list's item one-by-one. In case data object is a directory or JSON/YAML hash the variable represents an array of two items: file name/hash key and file content/hash value.

To iterate over Books in the previous example the following code can be used:
```
  {% for book in site.data.books %}
    Book "{{book[1].title}}" is stored in {{ book[0] }}.json file<br>
  {% endfor %}
```
It returns:

> Book "1st book" is stored in book1.json file
> Book "2nd book" is stored in book2.json file

To iterate over Authors array:
```
  {% for author in site.data.authors %}
    {{author.name}}'s id = {{author.id}}<br>
  {% endfor %}
```
The result:
> Jack London's id = 1

To filter array or hash item `if` tag inside the cycle can be used. Also it's possible to sort arrays using `sort` filter. This filter is not applicable to hashes, but another filter to convert a hash to array will be added later.

## Data Pages (Model-based Pages)
Modified version of [Jekyll Data Pages Generator](https://github.com/avillafiorita/jekyll-datapage_gen) is used to generate multiple pages using the same template. The plugin allows to define data array, rendering template and output folder to generate similar pages for every data item.

*CMS will provide the UI for editing source data. The Data Pages plugin supports any valid hash representation, using built-in data formats or any additional from a 3rd party plugin. However CMS editing accepts only JSON files as editable.*

**Data Pages can be generated only if they are based on a set of object files in one folder.**

The following example shows how to create a separate pages for the Books (defined earlier). Add a layout `_layout/book.html` to render Books data:

```
---
layout: default
---
<p>
    <h3>Group: {{ page.group.name }}</h3>
    <i>{{ page.title }}</i> by <b>{{ page.author.name }}</b>. <br>
    {{ page.description }}
</p>
```

Add Data Page definition into `_config.yml`
```
page_gen:
  - data: 'books'
    template: 'book'
    dir: 'book'
```

The output site include dynamic pages, e.g. `book/book1.html`
> #### Group: Group 2

> *1st book* by **Jack London**. 

> 1st description

### References to Data Pages
Described earlier `permalink` filter supports the following syntax:
```
{{ page | permalink[: locale: <language>] }}
```
Extended syntax for Model-based page is:
```
{{ <model-file-name> | permalink: model-dir:<model-directory-name>[, locale:<locale>] }}
```
So, there are three ways to obtain a Data Page permalink:


* `{{ page | permalink }}`: link to the current page (Data Page or not)
* `{{ 'book/book1' | permalink }}`: link to a page by path (Data Page or not)
* `{{ 'book1' | permalink: model_dir: 'book' }}`: link to a Data Page configured for 'book' directory (**TBD** *why not books?*)

### Data Pages localization
Data Pages can be localized using all methods described for standard pages.

## Static files
Files which don't have a Front Matter section are treated by Jekyll as static. They are not processed by Liquid preprocessors, not copied to locale folders and not supported by `permalink` filter. Static pages only copied to the output folder once.
