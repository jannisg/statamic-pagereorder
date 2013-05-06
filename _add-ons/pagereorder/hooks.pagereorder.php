<?php
class Hooks_pagereorder extends Hooks {

  /**
   *  We'll add our CSS styles to the head here.
   */
  public function add_to_control_panel_head() {
    // Check that we're on the correct page before loading assets.
    if ( self::current_route() == 'pages' ) {
      return self::include_css('page-reorder.min.css');
    } else {
      return "";
    }
  }

  /**
   *  We'll add our JavaScript just before the </body> tag.
   */
  public function add_to_control_panel_foot() {
    // Check that we're on the correct page before loading assets.
    if ( self::current_route() == 'pages' ) {
      return self::include_js('jquery.page-reorder.min.js');
    } else {
      return "";
    }
  }

  /**
   *  Handle the update of folder names as a callback to the JS reordering.
   */
  public function reorder() {

    // Get current user, to check if we're logged in.
    if ( ! Statamic_Auth::get_current_user()) {
      exit("Invalid Request");
    }

    // Create App Instance
    $app = \Slim\Slim::getInstance();

    // Get POST data from request.
    $order = $app->request()->post('order');

    // Make sure we've got a response.
    if ( !isset($order) ) {
      $message = Array(
        "status" => "error",
        "message" => "No page order data received. Please try again."
      );

      echo json_encode($message);
      return false;
    }

    // Get '_content' dir.
    $content_path = Statamic::get_content_root();

    // Get current folders within the content dir.
    // These are the ones we will be renaming.
    $folders = Statamic::get_content_tree();

    // Array of page order objects.
    $page_order = json_decode( $order );

    // Array to store the links of old data coupled with new data.
    // We return this to the view so we can use JS to update the pathing on the page.
    $links = Array();

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

        // Add item to $links.
        $links[] = Array( "old" => $old_name, "new" => $new_name );

        // Add slash to _content path, result should be '_content/'
        $folder_path = $content_path."/";

        // Generate pathing to pass to rename()
        $new_path = $folder_path.$new_name;
        $old_path = $folder_path.$old_name;

        // Rename folder unless the old and new names are identical.
        if ( $new_path !== $old_path ) {
          rename($old_path, $new_path);
        }
      } else {
        // We end up here if we've failed to match a folder/slug/url.
        // This is usually a sign that something was renamed and the
        // page wasn't refreshed thus working with outdated file paths/urls.

        // Bail out with message.
        $message = Array(
          "status" => "error",
          "message" => "There was an error saving your page order. Please try again."
        );

        echo json_encode($message);
        return false;
      }
    }

    $message = Array(
      "status" => "success",
      "message" => "Page order saved successfully!",
      "linkage" => $links
    );

    echo json_encode($message);
    return true;
  }

}