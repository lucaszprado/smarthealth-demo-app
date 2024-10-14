import { Controller } from "@hotwired/stimulus";
import { Chart, registerables } from "chart.js";

Chart.register(...registerables);

// Connects to data-controller="chart"
export default class extends Controller {
  static targets = ["canvas"];

  connect() {
    const ctx = this.canvasTarget.getContext("2d");

    // Example chart data and options, you can customize as needed
    const labels = [1,2,3,4,5,6,7];
    const upperBandY = 85;
    const lowerBandY = 45;

    const data = {
      labels: labels,
      datasets: [
      {
        label: 'Biomarker measures',
        data: [65, 59, 80, 90, 56, 55, 40],
        fill: false,
        borderColor: 'rgba(255, 136, 91, 0.5)',
        tension: 0.1,
        pointRadius: 6,
        pointBorderColor: 'rgba(255, 99, 132,0)',
        pointBackgroundColor: (context) => {
            const value = context.dataset.data[context.dataIndex];
            if (value > upperBandY) {
              return 'rgb(75, 192, 100)'
            } else if (value < lowerBandY) {
              return 'rgb(75, 192, 100)'
            } else {
              return 'rgb(255, 99, 132)'
            }
        }
      },
      {
        label: 'Lower band',
        data: [45, 45, 45, 45, 45, 45, 45],
        fill: false,
        borderColor: 'rgba(129, 176, 239, 0.3)',
        tension: 0.1,
        pointRadius: 0
      },
      {
        label: 'Upper band',
        data: [85, 85, 85, 85, 85, 85, 85],
        fill: 'origin',
        backgroundColor: (context) => {
            const ctx = context.chart.ctx;
            const chartHeight = context.chart.height;

            // Create a gradient to create the abrupt fill effect
            const gradient = ctx.createLinearGradient(0, 0, 0, chartHeight);

            // Abrupt fill up to y=45
            gradient.addColorStop(0, 'rgba(204, 229, 255, 0.2)'); // Solid fill from the top (y=85) to y=45
            gradient.addColorStop(0.55, 'rgba(204, 229, 255, 0.2)'); // Still solid at y=45
            gradient.addColorStop(0.55, 'rgba(255, 99, 132, 0)');   // Abruptly changes to transparent at y=45
            gradient.addColorStop(1, 'rgba(255, 99, 132, 0)');      // Fully transparent below y=45

            return gradient;
          },
        borderColor: 'rgba(129, 176, 239, 0.3)',
        tension: 0.1,
        pointRadius: 0
      }
      ]
    };

    const options = {
          scales: {
            y: {
              min: 0,
              max: 100,
              ticks: {
                stepSize: 10
              }
            }
          },
          plugins: {
            tooltip: {
              callbacks: {
                // Custom label to display only the y-axis value in the tooltip
                label: function(tooltipItem) {
                // Return only the y-axis value (which is the "raw" value of the point)
                return `${tooltipItem.raw}`;
                }
              }
            }
          }
        };

    // Initialize the chart
    new Chart(ctx, {
      type: 'line',  // or 'line', 'pie', etc.
      data: data,
      options: options
    });
  }
}
