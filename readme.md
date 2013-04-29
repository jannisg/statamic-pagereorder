# Statamic: Page Reorder

Adds AJAX drag and drop reordering of the top-level pages to your [Statamic](http://statamic.com/) control panel's "Pages" page.

## Installation

1. Drag the `/pagereorder/` folder _(located inside the `_add-ons` folder)_ into your `_add-ons/` folder of your Statamic installation.
2. Refresh the control panel's "Pages" page.

## Requirements

This add-on makes use of:

1. **jQuery**
2. **jQuery.easing**
3. **Underscore.js**
4. **HTML5 drag and drop API**.

jQuery, jQuery.easing and Underscore.js are all part of Statamics normal payload so we're just using what's already available there.

The drag and drop however needs the native HTML5 drag and drop api to work. If your browser doesn't support this then things aren't going to work…

If there is a need for it, I could look at adding fall back support for this using something like jQuery UI: Sortable for older browsers.

## What should you expect

1. Visiting the control panel's ("Pages") page, you will be able to drag and drop each **top level** page by clicking on the drag handle located to the left of the page title.
2. The homepage is "special" and is not affected by reordering nor can you drag it anywhere or other items above it.
3. Subpages cannot currently be reordered.

## To Do

- Have someone with better PHP skills code-review my code.
- Cross-browser test the JavaScript and CSS delivered by the add-on.
- Look into "subpages" reordering though this may be complicated by date sorting and other semantic ordering processes.
- Touch support

## Notes

**Use at your own risk.**

Check the To Do list and test things thoroughly yourself before any production use.

Because the actual API documentation isn't launched until Statamic hits version 1.5, this plugin may break when 1.5 is release so be aware of that.

## Want to help?

I haven't written much PHP code, usually working on more front-end related things, so if you know PHP I would love for you to review my existing code and let me know about any mistakes I may have made or how to improve any of the code in this add-on.

Also, I welcome any pull-requests to this add-on and would be happy to merge them into this add-on. When you send a pull-request however please be sure to comment your code so I can follow it more easily.