import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = ["statusClose", "statusOpen"]

  connect() {
    console.log("Hello from Toggle controller")
  }

  fire() {
    this.statusCloseTarget.classList.toggle("d-none")
    this.statusOpenTarget.classList.toggle("d-none")

  }

}
