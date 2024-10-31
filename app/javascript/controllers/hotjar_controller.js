import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hotjar"
export default class extends Controller {
  connect() {

    console.log("Hello from hotjar controller")
    this.loadHotjar();

  }

  loadHotjar() {
    // Hotjar initialization code
    (function(h, o, t, j, a, r) {
      h.hj = h.hj || function() { (h.hj.q = h.hj.q || []).push(arguments); };
      h._hjSettings = { hjid:5191202, hjsv: 6 };
      a = o.getElementsByTagName('head')[0];
      r = o.createElement('script'); r.async = 1;
      r.src = t + h._hjSettings.hjid + j + h._hjSettings.hjsv;
      a.appendChild(r);
    })(window, document, 'https://static.hotjar.com/c/hotjar-', '.js?sv=');
  }

}
