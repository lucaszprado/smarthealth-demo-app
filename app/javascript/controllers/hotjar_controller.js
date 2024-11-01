import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hotjar"
export default class extends Controller {
  connect() {
    console.log("Hello from hotjar controller")
    this.loadHotjar();

     // Ensure the script runs when the page is visited through a link
     document.addEventListener("turbo:load", () => {
      requestAnimationFrame(() => {
        this.loadHotjar();
      });
    });
  }

  disconnect() {
    // Clean up the event listener when the controller is disconnected
    document.removeEventListener("turbo:load", this.loadHotjar);
  }


  loadHotjar() {
    // Check if the Hotjar script is already loaded, and run it if necessary
    if (typeof window.hj === "undefined" || !window.hj) {
      console.log("Hotjar script initializing");

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

      console.log("Hotjar script loaded");
    }
  }
}
