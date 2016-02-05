# Basic Website Creation
The described example website is stored here: https://github.com/TravelTripperWeb/sample-website-tutorial

## Introduction
This README describes how to create a Jekyll-based website integrated with [TravelTripper CMS](www.traveltripper.io).

A TravelTripper CMS website can be developed locally using a number of plugins. These plugins add CMS integration and some usefull features which are described in this tutorial.

## Starting local development

To develop a CMS website the following is needed:

* Ruby and Gem
* Bundler: `gem install bundler`
* Required gems are listed in Gemfile.dev file, copy it inside your local development folder: `cp Gemfile.dev Gemfile`
* and install dependencies: `bundle install`

## Project structure

To create an empty project:

* copy `/_plugins` folder from the [repository](_plugins) to the root of your project.
* create default layout file: `/_layouts/default.html`

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

Run `jekyll serve` in the root of your project to view the result in your browser at http://localhost:4000.

This project supports many CMS extentions but doesn't use them yet.

## i18n
To localize a website, additional configuration is needed. Create `/_config.yml` file as following:
```
default_lang: 'en'
languages: ['en', 'ru']
exclude: ['sitemap.json']
```

This will copy pages for each non-default locale from the generated website to a locale sub-folder. A default language copy is stored
under the project root. So, after this update, we will see `/index.html` and `/ru/index.html` pages. However their
content will be the same.

## Translation tags
To add localized content (e.g. labels, captions, etc), translation keys and files should be used.

Create a `/_locales` folder and `/_locales/<language>.yml` files in [i18n format](http://guides.rubyonrails.org/i18n.html).
In dynamic pages (which contain [Front Matter](http://jekyllrb.com/docs/frontmatter/)), the liquid tag `t` can be used.

For example, create `/_locales/en.yml` file:
```
en:
  hello: 'EN hello label'
```
**A YAML locale file must be created for every specified language in /_config.yml, and at least one translation is needed in each file**.
Additional translation keys can be skipped, and in that case a warning message is shown: `translation missing: <locale>.<key>` as a result of `t` tag rendering.

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

A russian translation of the page (`/ru/index.html`) will show all keys as missed.

## Localizable properties

A page's [Front Matter](http://jekyllrb.com/docs/frontmatter/) can contain different variables which might be rendered via Liquid the liquid code: `{{ page.variable_name }}`.
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
By default, the output file name is not changed when page is generated. Programmers and CMS users can modify output URLs using `permalink` property in Front Matter section. This propery allows you to rename a page's URL in different locales. For example, add a localized permalink to `index.html`:
```
...
permalink_localized:
  ru: home.html
...
```

Because the `en` permalink is missing, it will generate the `en` translation using the file name and will be `/index.html`. The russian version will be available at `/ru/home.html`.

## References to a page
To create a url for another page, the `permalink` liquid filter is used. The syntax for it is:
```
{{ <page|path> | permalink[: locale:<locale>] }}
```
Where:
* `page`: Liquid's object: represents the current rendering page.
* `path`: A file's path, e.g. `/dir/file-name` for `/dir/file-name.html`
* `locale: <locale-value>`: a locale value/variable, to get a link to a particular translation. If locale is skipped then the current locale is used.


There is additional syntax for Model-based pages:
```
{{ <model-file-name> | permalink: model-dir:<model-directory-name>[, locale:<locale>] }}
```
which is descrabed in the section below.

## References to a page's translations
As metioned before, to obtain a localized URL to the current page, there is a simple synatax:
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

To handle current language there is `site.active_lang` variable. The liquid `if` tag allows highlighing current page's language.

The entire example of a language drop-down is shown below:

```
<select id="language" onchange="location = this.options[this.selectedIndex].value;">
  {% for lang in site.languages %}
    <option {% if lang == site.active_lang %} selected="true" {% endif%} value="{{ page | permalink: locale: lang }}">
      {{ lang | upcase }}
    </option>
  {% endfor %}
</select>
```

## Editable Regions

The plugins allow you to define a region which is editable via CMS.
Every region can contain different region items. Each item is loaded from a data file and rendered using a particular template (which is referenced by the item's data). Regions are unique within each page/locale combination.

The liquid tag `region` requires one constant parameter which defines region's name. Add the following content to `index.html`:
```
{% region region1 %}
```
To edit the region's content manually, create the file `/_data/_regions/en/index.html/region1.json` as follows:
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
The rendered page will now include:

> 1st item

> 2nd item

And contain the html:

```
<p>1st item</p><p>2nd item</p>
```

Translated versions of the page won't show any region content since we didn't create the json file for them.

Region data is stored in the folder named `/_data/_regions/<language>/<page_path>/<region_name>.json` folder. The file will be created by the CMS when a user edits region's content in the CMS UI. If the file is created manually by a developer, it must be a valid JSON file that defines an array of region items. Every item must include the `_template` and `content` properties.

A region item's template is used to render the data in the generated page. The `html` template is buit-in, however others template can be created or the `html` template can be overwritten. Create the file `/_data/_includes/_regions/html`:
```
Custom HTML template: {{include.instance.content}}
```

After the update the generated page would contain:
> Custom HTML template:

> 1st item
>
> Custom HTML template:

> 2nd item

And contain the html:

```
Custom HTML template: <p>1st item</p>Custom HTML template: <p>2nd item</p>
```

The variable `include.instance` is a reference to a region item object in the JSON, so any additional fields can be used both in the Region item and its template. The CMS allows users to edit HTML region items, and the ability to create editors for additional regtion item types will be added later.

### Includes and Editable Regions
Regions can also be defined in include files, but the region data is still specific to the primary page being rendered. For example, create the include file `/_includes/reg_sample.html`.
```
Included region: {% region region1 %}
```

Add a liquid `include` tag into `index.html`:
```
{% include reg_sample.html %}
```
As a result - the same `region1` block will be rendered twice on the page: firstly by the direct `region` tag, and then via the included `reg_sample.html` file.

## Custom templates and Widgets
Custom templates allow rendering a custom data structure as region content. The CMS only has an HTML editor as a defaut built-in editor. To extend the CMS UI and allow editing region items based on a custom template, the files `_widgets/show.html` and `_widgets/edit.html` are needed. Those files are loaded when preview and edit screens are opened in the CMS's region editor.

The limitations for those files are:
* Files must have valid HAML content. In case plain text is used, it's important to avoid any indentation
* AngularJS bindings must be used to show and update PED content. There are `ped` and `content` variables in Angular's scope. The `ped` variable allows you to define any additional attribute for a PED object. `content` variable is set to PED's object `content` attribute.
* Files should define `ng-template`s with an `id` of `template_name.show` or `template_name.edit`.

As an example, the following can be used to define three types of widgets 'text' and 'text1' (which are identical), and 'color_text' which has the additional property 'color' and uses the property 'text' instead of 'content'.
> _widgets/show.html

```
%script(id="text.show" type="text/ng-template")
  %p.ped-list_item_text
    {{ ped.content }}
<script id="text1.show" type="text/ng-template">
<p class="ped-list_item_text">
{{ ped.content }}
</p>
</script>
%script(id="color_text.show" type="text/ng-template")
  %p.ped-list_item_text(ng-style="{color: ped.color}")
    {{ ped.text }}
```

> _widgets/edit.html

```
%script(id="text.edit" type="text/ng-template")
  %textarea(ng-model="ped.content")
<script id="text1.edit" type="text/ng-template">
<textarea ng-model="ped.content"></textarea>
</script>
%script(id="color_text.edit" type="text/ng-template")
  %div(ng-init="colors=['red', 'blue', 'green']")
    Select a color:
    %select(ng-options="color for color in colors track by color" ng-model="ped.color")
    Text
    %input(ng-model="ped.text")
```

## Data references
The plugins add the ability to reference any Jekyll model data. To activate it:
* store data objects in a folder or file named as a plural noun, e.g. `_data/_models/groups/*.json` (where each file will be a JSON hash defining a single object) or `_data/_models/groups.json` (which is an array of JSON hash objects).
* add a numeric `id` field to a each object
* add an association field to reference another object using a singular noun (e.g. a `book1.json` file might have a field `group` that references a particular group object)

When using this structure, an objects reference will be autoloaded for page generation, so the following syntax can be used in a liquid tag in a page template: `book.group.name`.

The following example demonstrate this feature using single and multiple files to store data.

Create `/_data/_models/authors.json` to store an array of Authors:

```
[
    {
        "id": 1,
        "name": "Jack London"
    }
]
```

Create `/_data/_models/groups` folder to store Groups as separate files:
> /_data/_models/groups/1.json

```
{
  "id": 1,
  "name": "Group 1"
}
```

> /_data/_models/groups/2.json

```
{
  "id": 2,
  "name": "Group 2"
}
```

Create `/_data/_models/books` folder to store Books objects as separate files. Each Book will refer to an Author and Group:

> /_data/_models/books/1.json

```
{
  "author": 1,
  "group": 2,
  "title": "1st book",
  "description": "1st description"
}
```

> _data/_models/books/2.json

```
{
  "author": 1,
  "group": 1,
  "title": "2nd book",
  "description": "2nd description",
}
```
When rendered, every Book object has `author` and `group` properties, e.g. `{{ site.data._models.books[1].author.name }}`
and `{{ site.data._models.books[1].group.name }}`. The next topic explains how to iterate over that data to render it.

## Data iteration
This section explains the standard Liquid approach to iterating over data arrays or hashes.

Liquid support  `for` cycle:
```
{% for my_obj in site.data._models.<data-object> %}
  {{ my_obj.<property-name> }}
{% endfor %}
```
where "data-object" is a directory or file name (including the path but excluding a file extention). If the data object represents an array (e.g. CSV file, JSON array or YAML list,) the declared variable `my_obj` is set to each list item for each iteration of the for loop. If the data object is a directory or JSON/YAML hash, then the variable `my_obj` will be an array of two items: the file name or hash key, and the file content or hash value.

To iterate over Books in the previous example the following code can be used:
```
  {% for book in site.data._models.books %}
    Book "{{book.title}}"<br>
  {% endfor %}
```
It returns:

> Book "1st book"
> Book "2nd book"

To iterate over Authors array:
```
  {% for author in site.data._models.authors %}
    {{author.name}}'s id = {{author.id}}<br>
  {% endfor %}
```
The result:
> Jack London's id = 1

To filter an array or hash item, the `if` tag inside the cycle can be used. It is also possible to sort arrays using the liquid `sort` filter. This filter is not applicable to hashes, but another filter to convert a hash to an array will be added later.

## Data Pages (Model-based Pages)
A modified version of [Jekyll Data Pages Generator](https://github.com/avillafiorita/jekyll-datapage_gen) is used to generate multiple pages using the same template. The plugin allows you to configure a data array, a rendering template and an output folder to generate similar pages for every data item.

*The CMS will provide the UI for editing source data. The Data Pages plugin supports any valid hash representation, using built-in data formats or any additional from a 3rd party plugin. However, CMS editing uses only JSON files.*

**Data Pages can be generated only if they are based on a set of object files in one folder, not a single file with an array of objects.**

The following example shows how to create separate pages for each Book object (defined earlier). Add a layout `/_layout/book.html` to render Books data:

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
  - model: 'books'
    layout: 'book'
    dir: 'book'
```

The output site includes dynamic pages, e.g. `/book/book1.html`
> #### Group: Group 2

> *1st book* by **Jack London**.

> 1st description

### References to Data Pages
The previously described `permalink` filter supports the following syntax:
```
{{ page | permalink[: locale: <language>] }}
```
The extended syntax for a Model-based page is:
```
{{ <model-file-name> | permalink: model-dir:<model-directory-name>[, locale:<locale>] }}
```
So, there are three ways to obtain a Data Page permalink:


* `{{ page | permalink }}`: link to the current page (Data Page or not)
* `{{ 'book/book1' | permalink }}`: link to a page by path (Data Page or not), assuming files are generated according to the config above
* `{{ 'book1' | permalink: model_dir: 'book' }}`: link to a Data Page configured for 'book' directory (**TBD** *why not books?*)

### Data Pages localization
Data Pages can be localized using all methods described for standard pages.

## Static files
Files which don't have a Front Matter section are treated by Jekyll as static. They are not processed by Liquid preprocessors, not copied to locale folders and can not be referenced by the `permalink` filter. Static pages are only copied to the output folder once.
