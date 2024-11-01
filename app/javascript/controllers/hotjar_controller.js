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
    this.reloadHotjar();
    if (typeof window.hj === "function") {
      // Notify Hotjar of a new page state
      console.log("Hotjar stateChange triggered");
      window.hj('stateChange', window.location.pathname);
    }
  }

  loadHotjar() {
    console.log("loadHotjar() called");

    (function(h, o, t, j, a, r) {
      h.hj = h.hj || function() { (h.hj.q = h.hj.q || []).push(arguments); };
      h._hjSettings = { hjid:5191202, hjsv: 6 };
      a = o.getElementsByTagName('head')[0];
      r = o.createElement('script'); r.async = 1;
      r.src = t + h._hjSettings.hjid + j + h._hjSettings.hjsv;
      a.appendChild(r);
    })(window, document, 'https://static.hotjar.com/c/hotjar-', '.js?sv=');

    console.log("Hotjar script added to the DOM");
  }

  reloadHotjar() {
    console.log("Reloading Hotjar script");

    // Remove existing script tag if present
    const existingScript = document.querySelector('script[src^="https://static.hotjar.com"]');
    if (existingScript) {
      existingScript.remove();
      console.log("Existing Hotjar script removed");
    }

    // Re-add the Hotjar script
    this.loadHotjar();
  }

}
