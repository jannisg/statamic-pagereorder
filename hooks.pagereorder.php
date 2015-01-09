<?php
class Hooks_pagereorder extends Hooks {

  public $meta = array(
     'name'       => 'Page Reorder',
     'version'    => '0.1.3',
     'author'     => 'Jannis Gundermann',
     'author_url' => 'http://jannisgundermann.com'
   );

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
    if ( ! Auth::getCurrentMember()) {
      exit("Invalid Request");
    }

    // Get POST data from request.
    $order = Request::post('order', false);

    // Make sure we've got a response.
    if ( $order == FALSE ) {
      $msg = "No page order data received. Please try again.";
      $message = Array(
        "status" => "error",
        "message" => $msg
      );

      Log::error($msg, 'pagereorder');

      echo json_encode($message);
      return false;
    }

    // Get '_content' dir.
    $content_path = Config::getContentRoot();

    // Get current folders within the content dir.
    // These are the ones we will be renaming.
    $content = Statamic::get_content_tree();

    // filter array of items to only return folders.
    function get_folders($item) {
      return( isset($item['type']) && $item['type'] == 'folder' );
    };
    $folders = array_filter($content, "get_folders");

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

          // Check the old path actually exists and the new one doesn't.
          if ( Folder::exists($old_path) && !Folder::exists($new_path) ) {
            rename($old_path, $new_path);

          } else {
            $msg = "Aborting... could not guarantee file integrity for folders: $old_path and $new_path!";

            $message = Array(
              "status" => "error",
              "message" => $msg
            );

            Log::error($msg, 'pagereorder');

            echo json_encode($message);
            return false;
          }
        }

      } else {
        // We end up here if we've failed to match a folder/slug/url.
        // This is usually a sign that something was renamed and the
        // page wasn't refreshed thus working with outdated file paths/urls.

        // Bail out with message.
        $msg = "There was an error saving your page order. Please try again.";

        $message = Array(
          "status" => "error",
          "message" => $msg
        );

        Log::error($msg, 'pagereorder');

        echo json_encode($message);
        return false;
      }
    }

    $msg = "Page order saved successfully!";
    $message = Array(
      "status" => "success",
      "message" => $msg,
      "linkage" => $links
    );

    Log::info($msg, 'pagereorder');

    echo json_encode($message);
    return true;
  }

}