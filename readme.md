# Statamic: Page Reorder

Adds AJAX drag and drop reordering of the top-level pages to your [Statamic](http://statamic.com/) control panel's "Pages" page.

## Installation

### 1. GIT Clone

1. `git clone git@github.com:jannisg/statamic-pagereorder.git pagereorder` into your `_add-ons` directory.

**Note:** If you're using the `1.5 beta` build of Statamic run `git checkout -b 1.5b origin/1.5b` from within the `_add-ons/pagereorder` folder.

---

### 2. Download

1. Download the correct branch (`1.5b` if you're using 1.5beta version of Statamic, otherwise `master`)
2. Extract the downloaded archive and rename the folder to `pagereorder`.
3. Drag this `pagereorder` folder into the `_add-ons` folder at the root of your Statamic installation.

## Requirements

This add-on makes use of:

1. **jQuery**
2. **jQuery.easing**
3. **Underscore.js**
4. **HTML5 drag and drop API**.

jQuery, jQuery.easing and Underscore.js are all part of Statamics normal payload so we're just using what's already available there.

The drag and drop however needs the native HTML5 drag and drop api to work. If your browser doesn't support this then things aren't going to work…

If there is a need for it, I could look at adding fall back support for this using something like jQuery UI: Sortable for older browsers.

## Browser Support

This add-on has been tested successfully in: Chrome, Safari, Firefox and Internet Explorer 10.
**Note:** Touch devices are currently not supported.

Support for Internet Explorer 9 and lower could potentially be added, please file a GitHub issue if you'd like to see IE8/9 support.

## What should you expect

1. Visiting the control panel's ("Pages"/"Dashboard") page, you will be able to drag and drop each **top level** page by clicking on the drag handle located to the left of the page title.
2. The homepage is "special" and is not affected by reordering nor can you drag it anywhere or other items above it.
3. Subpages cannot currently be reordered.

## To Do

- Touch support
- Look into "subpages" reordering though this may be complicated by date sorting and other semantic ordering processes.

## Source Files

If you'd like to make modifications or view the uncompressed code, the source files are included in the `/src/` directory.
To make modifications be sure to use the [Grunt JS](http://gruntjs.com/) task runner provided.

Setting up the task runner is fairly easy, go into the `pagereoder` folder, run `npm install` _(you obviously need to have NodeJS installed for this to work)_ and then run either:

- **`grunt`** to compile your changes into the compressed output served by the plugin.
- **`grunt watch`** to auto compile during development.

If you have no interest in making modifications, you can safely delete the following files/folders:

- `Gruntfile.coffee`
- `package.json`
- `.gitignore`
- `src/`

## Notes

**Use at your own risk.**

Check the To Do list and test things thoroughly yourself before any production use.

Because the actual API documentation isn't launched until Statamic hits version 1.5, this plugin may break when 1.5 is release so be aware of that.

## Attributions

This add-on uses the [HTML5 Sortable](https://github.com/farhadi/html5sortable/) plugin.

## License

This add-on is released under the MIT license.