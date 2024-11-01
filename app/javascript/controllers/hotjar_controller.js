import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hotjar"
export default class extends Controller {
  connect() {
    console.log("Hello from hotjar controller - connect() called");
    this.loadHotjar();
    document.addEventListener("turbo:load", this.handleTurboLoad.bind(this));
  }

  disconnect() {
    console.log("Hotjar controller - disconnect() called");
    document.removeEventListener("turbo:load", this.handleTurboLoad.bind(this));
  }

  handleTurboLoad() {
    console.log("turbo:load event detected");
    this.loadHotjar();
  }

  loadHotjar() {
    console.log("loadHotjar() called");
    // Check if the Hotjar script is already loaded, and run it if necessary
    if (typeof window.hj === "function") {
      console.log("Reinvoking Hotjar tracking function");
      window.hj('trigger', 'page_view'); // This will re-trigger Hotjar tracking for a new page view
    } else {
      console.log("Initializing Hotjar script");

    //const timestamp = new Date().getTime(); // Add const here
      (function(h, o, t, j, a, r) {
        h.hj = h.hj || function() { (h.hj.q = h.hj.q || []).push(arguments); };
        h._hjSettings = { hjid:5191202, hjsv: 6 };
        a = o.getElementsByTagName('head')[0];
        r = o.createElement('script'); r.async = 1;
        r.src = t + h._hjSettings.hjid + j + h._hjSettings.hjsv;
        // r.src = `${t + h._hjSettings.hjid + j + h._hjSettings.hjsv}&cacheBuster=${timestamp}`;
        a.appendChild(r);
      })(window, document, 'https://static.hotjar.com/c/hotjar-', '.js?sv=');

      console.log("Hotjar script added to the DOM");
    }
  }
}
