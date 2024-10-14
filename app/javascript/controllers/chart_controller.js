import { Controller } from "@hotwired/stimulus";
import { Chart, registerables } from "chart.js";

Chart.register(...registerables);

// Connects to data-controller="chart"
export default class extends Controller {
  static targets = ["canvas"];
  static values = {
    biomarkerMeasures: Object
  };

  connect() {
    console.log("Entrei");

    const chartData = this.biomarkerMeasuresValue;
    const ctx = this.canvasTarget.getContext("2d");


    // Example chart data and options, you can customize as needed
    const labels = Object.keys(chartData);
    const upperBandY = 85;
    const lowerBandY = 45;

    const data = {
      labels: labels,
      datasets: [
      {
        label: 'Biomarker measures',
        data: Object.values(chartData), // Biomarker measures
        fill: false,
        borderColor: 'rgba(255, 136, 91, 0.5)',
        tension: 0.1,
        pointRadius: 6,
        pointBorderColor: 'rgba(255, 99, 132,0)',
        pointBackgroundColor: (context) => {
            const value = context.dataset.data[context.dataIndex];
            if (value > upperBandY) {
              return 'rgb(255, 255, 102)'
            } else if (value < lowerBandY) {
              return 'rgb(255, 255, 102)'
            } else {
              return 'rgb(51, 255, 153)'
            }
        }
      },
      {
        label: 'Lower band',
        data: Array(labels.length).fill(lowerBandY),
        fill: false,
        borderColor: 'rgba(129, 176, 239, 0.3)',
        tension: 0.1,
        pointRadius: 0
      },
      {
        label: 'Upper band',
        data: Array(labels.length).fill(upperBandY),
        fill: 'origin',
        backgroundColor: (context) => {
            const ctx = context.chart.ctx;
            const chartHeight = context.chart.height;

            // Create a gradient to create the abrupt fill effect
            const gradient = ctx.createLinearGradient(0, 0, 0, chartHeight);

            // Abrupt fill up to y=45
            gradient.addColorStop(0, 'rgba(204, 229, 255, 0.2)'); // Solid fill from the top (y=85) to y=45
            gradient.addColorStop(0.73, 'rgba(204, 229, 255, 0.2)'); // Still solid at y=45
            gradient.addColorStop(0.73, 'rgba(255, 99, 132, 0)');   // Abruptly changes to transparent at y=45
            gradient.addColorStop(0.73, 'rgba(255, 99, 132, 0)');      // Fully transparent below y=45

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
        x: {
         // type: 'timeseries',
          grid: {
            display: false,
          },
          //offset: true,
          ticks: {
            padding: 1,
          }
        },
        y: {
          grid:{
            display: false
          },
          min: 30,
          max: 100,
          ticks: {
            stepSize: 10,
            padding: 30,
            display: true
          },
          border: {
            display: false
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
