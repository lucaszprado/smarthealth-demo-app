import { Controller } from "@hotwired/stimulus";
import { Chart, registerables } from "chart.js";

Chart.register(...registerables);

// Connects to data-controller="chart"
export default class extends Controller {
  static targets = ["canvas"];
  static values = {
    biomarkerMeasures: Object,
    biomarkerUpperBand: Number,
    biomarkerLowerBand: Number
  };

  connect() {
    console.log("Entrei");

    const chartData = this.biomarkerMeasuresValue;
    const ctx = this.canvasTarget.getContext("2d");

    // X-axis, upper band and lower band
    const labels = Object.keys(chartData);
    const biomarkerSeries = Object.values(chartData);
    const upperBandY = this.biomarkerUpperBandValue;
    const lowerBandY = this.biomarkerLowerBandValue;

    // Defining chart Y range constants
    const biomarkerHighest = Math.max(...biomarkerSeries);
    const biomarkerLowest = Math.min(...biomarkerSeries);
    const upperYAxis = 1.2*Math.max(biomarkerHighest, upperBandY);
    const lowerYAxis = 0.7*Math.min(biomarkerLowest, lowerBandY);

    debugger
    const data = {
      labels: labels,
      datasets: [
      {
        label: 'Biomarker measures',
        data: biomarkerSeries, // Biomarker measures
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
            const canvas = context.chart.canvas;

            // const chartArea = context.chart.chartArea;
            // debugger
            // const chartHeight = chartArea.bottom - chartArea.top; // Height of the chart area
            // const gradient = ctx.createLinearGradient(0, chartArea.top, 0, chartArea.bottom); // Gradient vector (x0, y0, x1, y1)
            const gradient = ctx.createLinearGradient(0, 0, 0, canvas.height); // Gradient vector (x0, y0, x1, y1)
            // Calculate gradient markers as percentage of chart height

            const upperBandPosition = (upperYAxis - upperBandY) / (upperYAxis - lowerYAxis);
            const lowerBandPosition = (upperYAxis - lowerBandY) / (upperYAxis - lowerYAxis);

            //debugger
            // Add color stops for the gradient
            gradient.addColorStop(0, 'rgba(204, 229, 255, 0.2)'); // Light blue at the top
            gradient.addColorStop(upperBandPosition, 'rgba(204, 229, 255, 0.2)'); // Solid blue starting from the upper band
            gradient.addColorStop(lowerBandPosition, 'rgba(204, 229, 255, 0)');   // Transparent from lower band
            gradient.addColorStop(1, 'rgba(204, 229, 255, 0)');   // Transparent at the bottom

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
            padding: 15,
          }
        },
        y: {
          grid:{
            display: false
          },
          min: lowerYAxis,
          max: upperYAxis,
          ticks: {
            stepSize: Math.round((upperYAxis - lowerYAxis)/8),
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
