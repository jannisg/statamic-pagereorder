<?php
class Hooks_pagereorder extends Hooks {

  /**
   *  We'll add our CSS styles to the head here.
   */
  public function control_panel__add_to_head() {
    // If we're not on the /pages page, then don't load the CSS.
    if ( URL::getCurrent(false) != '/pages' ) { return ""; }
    return $this->css->link('page-reorder.min.css');
  }

  /**
   *  We'll add our JavaScript just before the </body> tag.
   */
  public function control_panel__add_to_foot() {
    // If we're not on the /pages page, then don't load the JS.
    if ( URL::getCurrent(false) != '/pages' ) { return ""; }
    return $this->js->link('jquery.page-reorder.min.js');
  }

  /**
   *  Handle the update of folder names as a callback to the JS reordering.
   */
  public function pagereorder__reorder() {

    // Get current user, to check if we're logged in.
    if ( ! Statamic_Auth::get_current_user()) {
      exit("Invalid Request");
    }

    // Create App Instance
    $app = \Slim\Slim::getInstance();

    // Get POST data from request.
    $order      = $app->request()->post('order');
    $return_url = $app->request()->getReferer();

    // Make sure we've got a response.
    if ( !isset($order) ) { return false; }

    // Get '_content' dir.
    $content_path = Statamic::get_content_root();

    // Get current folders within the content dir.
    // These are the ones we will be renaming.
    $folders = Statamic::get_content_tree();

    // Array of page order objects.
    $page_order = json_decode( $order );

    // Loop over original folder structure and rename all folders to
    // reflect the new order.
    foreach ($folders as $folder) {
      // Store original folder data.
      $url    = $folder['url'];       // used for matching original with new data.
      $slug   = $folder['slug'];      // used to generate the old pathing info.

      // Match on the URL to get the correct order result for this item.
      $match = Array();
      // Loop through all results.
      foreach ($page_order as $page) {
        // Compare page order results URL key with our old URL.
        // They should match.
        if ( isset($page->url) && $page->url == $url ) {
          $match[] = $page;

          // reduce the variable to the object, so we can do $match->key
          // instead of $match[0]->key
          $match = $match[0];

          // there will naturally only be one match on the URL so bail once we've found one.
          break;
        }
      }

      // If we've found a match, let's get the pathing info.
      if ( isset($match) && sizeof($match) > 0 ) {

        // Filenames
        $new_name = $match->index.'-'.preg_replace("/^\/(.+)/uis", "$1", $match->url);
        $old_name = $slug;

        // Add slash to _content path, result should be '_content/'
        $folder_path = $content_path."/";

        // Generate pathing to pass to rename()
        $new_path = $folder_path.$new_name;
        $old_path = $folder_path.$old_name;

        // Rename folder unless the old and new names are identical.
        if ( $new_name !== $old_name ) {
          rename($old_path, $new_path);
        }
      } else {
        // If we couldn't find a match, bail out with a message.
        $app->flash('error', 'There was an error saving your page order. Please try again or ask for help in the forums.');
        $app->redirect( $return_url );

        return false;
      }
    }

    // Success, back to the page tree.
    $app->flash('success', 'Page order saved successfully!');
    $app->redirect( $return_url );

    return true;
  }

}