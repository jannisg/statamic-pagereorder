# Statamic: Page Reorder

Adds AJAX drag and drop reordering of the top-level pages to your [Statamic](http://statamic.com/) control panel's "Pages" page.

## Installation

### 1. GIT Clone

1. `git clone git@github.com:jannisg/statamic-pagereorder.git pagereorder` into your `_add-ons` directory.

---

### 2. Download

1. Download the `master` branch if you are using Statamic 1.5 or later (or the `1.4.2` branch if you're using that version of Statamic)
2. Extract the downloaded archive and rename the folder to `pagereorder`.
3. Drag this `pagereorder` folder into the `_add-ons` folder at the root of your Statamic installation.

## Requirements

This add-on makes use of:

1. **jQuery** _(already part of the Statamic Admin UI)_
2. **jQuery.easing** _(already part of the Statamic Admin UI)_
3. **Underscore.js** _(already part of the Statamic Admin UI)_
4. **HTML5 drag and drop API**.

jQuery, jQuery.easing and Underscore.js are all part of Statamics normal payload so we're just using what's already available there.

The drag and drop however needs the native HTML5 drag and drop api to work. If your browser doesn't support this then things aren't going to work…

If there is a need for it, I could look at adding fall back support for this using something like jQuery UI: Sortable for older browsers.

## Browser Support

This add-on has been tested successfully in: Chrome, Safari, Firefox and Internet Explorer 10.
**Note:** Touch devices are currently not supported.

Support for Internet Explorer 9 and lower could potentially be added, please file a GitHub issue if you'd like to see IE8/9 support.

## What should you expect

1. Visiting the control panel's ("Pages"/"Dashboard") page, you will be able to drag and drop each top-level page and numerically sorted subpages by clicking on the drag handle located to the left of the page title.
2. Standalone pages are "special" and are not affected by reordering nor can you drag them anywhere.
3. ~~Subpages cannot currently be reordered.~~ _This is possible with version `0.3.0`._

## To Do

- Touch support

## Source Files

If you'd like to make modifications or view the uncompressed code, the source files are included in the `/src/` directory.
To make modifications be sure to use the [Grunt JS](http://gruntjs.com/) task runner provided.

Setting up the task runner is fairly easy, go into the `pagereoder` folder, run `npm install` _(you obviously need to have NodeJS installed for this to work)_ and then run either:

- **`grunt`** to compile your changes into the compressed output served by the plugin.
- **`grunt watch`** to auto compile during development.

If you don't have any interest in making modifications to this add-on yourself, you can safely delete the following files/folders:

- `Gruntfile.coffee`
- `package.json`
- `.gitignore`
- `src/`

## Notes

**Use at your own risk.**

Check the To Do list and test things thoroughly yourself before any production use.

## Attributions

This add-on uses the [HTML5 Sortable](https://github.com/farhadi/html5sortable/) plugin.

## License

This add-on is released under the MIT license.