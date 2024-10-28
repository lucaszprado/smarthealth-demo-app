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
    const highestYValue = Math.max(biomarkerHighest, upperBandY);
    const lowestYValue = 0*Math.min(biomarkerLowest, lowerBandY);

    // debugger
     // Add two placeholder labels to center the point
     labels.unshift(""); // Add an empty label at the beginning
     labels.push("");     // Add an empty label at the end

     // Add placeholder null values to maintain dataset length
     biomarkerSeries.unshift(null); // Empty value at the beginning
     biomarkerSeries.push(null);    // Empty value at the end

    const pointColor = (context) => {
      const value = context.dataset.data[context.dataIndex];
          if (value > upperBandY) {
            return '#E7EE33'
          } else if (value < lowerBandY) {
            return '#E7EE33)'
          } else {
            return '#044E0C'
          }
    };

    // Helper function to calculate step size
    function calculateStepSize(min, max) {
      const range = max - min;
      if (range <= 50) return 10;          // Small range
      if (range <= 100) return 20;        // Medium range
      return Math.ceil(range / 5);       // Larger range, divide range by 5
    }

    Chart.defaults.font = {
      family: '"Work Sans", "Helvetica", "sans-serif"', // Set the font family
      size: 14, // Set the font size in pixels
      weight: 'normal', // Optional: Set font weight
      lineHeight: 1.2, // Optional: Set line height
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

            // Defining position of the bands in terms of fractions of Y axis to apply the gradient.
            const lowerYAxis = Math.round(lowestYValue);
            const upperYAxis = calculateStepSize(Math.round(lowestYValue), Math.round(highestYValue))*6;

            const upperBandPosition = (upperYAxis - upperBandY) / (upperYAxis - lowerYAxis);
            const lowerBandPosition = (upperYAxis - lowerBandY) / (upperYAxis - lowerYAxis) - 0.001;
            // debugger
            // Add color stops for the gradient
            //gradient.addColorStop(0, 'rgba(155, 238, 155, 0.3)'); // Light green at the upper band
            gradient.addColorStop(upperBandPosition, 'rgba(155, 238, 155, 0.1)'); // light green starting at the upper band
            gradient.addColorStop(lowerBandPosition, 'rgba(155, 238, 155, 0.1)');   // light green at the lower band
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
      responsive: true, // This makes the chart automatically resize to fit its container
      maintainAspectRatio: false, // Allows the chart to fill its container’s width and height
      scales: {
        x: {
         // type: 'timeseries',
          grid: {
            display: false,
          },
          //offset: true,
          ticks: {
            padding: window.innerWidth < 576 ? 5 : 15,  // Adjust padding based on screen width
            autoSkip: true,  // Auto-skip labels if there’s overlap
            maxRotation: window.innerWidth < 576 ? 45 : 0,  // Rotate labels on mobile
            minRotation: window.innerWidth < 576 ? 45 : 0,  // Keep rotation consistent
            font: {
              size: window.innerWidth < 576 ? 10 : 14,  // Reduce font size on small screens
            }
          }
        },
        y: {
          grid:{
            display: false
          },
          min: Math.round(lowestYValue),
          max: calculateStepSize(Math.round(lowestYValue), Math.round(highestYValue))*6,
          ticks: {
            // stepSize: Math.ceil((upperYAxis - lowerYAxis)/5),
            padding: window.innerWidth < 576 ? 5 : 30,
            display: true,
            font: {
              size: window.innerWidth < 576 ? 10 : 14,  // Reduce font size on small screens
            },
            stepSize: calculateStepSize(Math.round(lowestYValue), Math.round(highestYValue)),  // Custom step size
            callback: function(value) {
              return Math.round(value);  // Show rounded values without precise decimal points
            }
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
        },
        legend: {
          display: false
        }
      },
    };

    const chartContainer = document.querySelector('.chart-container'); // Assuming you have a container
    chartContainer.style.minHeight = '25rem';

    debugger
    // Initialize the chart
    new Chart(ctx, {
      type: 'line',  // or 'line', 'pie', etc.
      data: data,
      options: options
    });
  }
}
