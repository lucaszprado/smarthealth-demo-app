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

     // Add two placeholder labels to center the point
     labels.unshift(""); // Add an empty label at the beginning
     labels.push("");     // Add an empty label at the end

     // Add placeholder null values to maintain dataset length
     biomarkerSeries.unshift(null); // Empty value at the beginning
     biomarkerSeries.push(null);    // Empty value at the end

    const pointColor = (context) => {
      const value = context.dataset.data[context.dataIndex];
          if (value > upperBandY) {
            return '#F7F7BE'
          } else if (value < lowerBandY) {
            return '#F7F7BE)'
          } else {
            return '#044E0C'
          }
    };

    const data = {
      labels: labels,
      datasets: [
      {
        label: 'Biomarker measures',
        data: biomarkerSeries, // Biomarker measures
        fill: false,
        borderColor: '#B9D7FA',
        tension: 0.1,
        pointRadius: 6,
        pointBorderColor: pointColor,
        pointBackgroundColor: pointColor
      },
      {
        label: 'Lower band',
        data: Array(labels.length).fill(lowerBandY),
        fill: false,
        borderColor: 'rgba(155, 238, 155, 0.3)',
        tension: 0.1,
        pointRadius: 0
      },
      {
        label: 'Upper band',
        data: Array(labels.length).fill(upperBandY),
        fill: 'origin',
        backgroundColor: (context) => {
          const ctx = context.chart.ctx;
          const chartArea = context.chart.chartArea;

          if (!chartArea) {
            return 'Wainting';
          }
          const gradient = ctx.createLinearGradient(0, chartArea.top, 0, chartArea.bottom);
            // const ctx = context.chart.ctx;
            // const canvas = context.chart.canvas;
            // const gradient = ctx.createLinearGradient(0, 0, 0, canvas.height); // Gradient vector (x0, y0, x1, y1)

            const upperBandPosition = (upperYAxis - upperBandY) / (upperYAxis - lowerYAxis);
            const lowerBandPosition = (upperYAxis - lowerBandY) / (upperYAxis - lowerYAxis);
            //debugger
            // Add color stops for the gradient
            gradient.addColorStop(0, 'rgba(155, 238, 155, 0.3)'); // Light green at the top
            gradient.addColorStop(upperBandPosition, 'rgba(155, 238, 155, 0.1)'); // Solid green starting from the upper band
            gradient.addColorStop(lowerBandPosition, 'rgba(155, 238, 155, 0.1)');   // Transparent from lower band
            gradient.addColorStop(lowerBandPosition + 0.001, 'rgba(155, 238, 155, 0)');   // Transparent from lower band
            gradient.addColorStop(1, 'rgba(155, 238, 155, 0)');   // Transparent at the bottom

            return gradient;
          },
        borderColor: 'rgba(155, 238, 155, 0.3)',
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
          min: Math.round(lowerYAxis),
          max: Math.round(upperYAxis),
          ticks: {
            stepSize: Math.ceil((upperYAxis - lowerYAxis)/5),
            padding: 30,
            display: true,
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
      },
    };

    //debugger

    // Initialize the chart
    new Chart(ctx, {
      type: 'line',  // or 'line', 'pie', etc.
      data: data,
      options: options
    });
  }
}
