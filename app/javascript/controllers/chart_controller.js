import { Controller } from "@hotwired/stimulus";
import { Chart, registerables } from "chart.js";

Chart.register(...registerables);

// Connects to data-controller="chart"
export default class extends Controller {
  static targets = ["canvas"];
  static values = {
    biomarkerMeasures: Object,
    biomarkerUpperBand: Object,
    biomarkerLowerBand: Object
  };

  connect() {
    console.log("Entrei");
    const ctx = this.canvasTarget.getContext("2d");
    const biomarkerMeasures = this.biomarkerMeasuresValue;
    const biomarkerUpperBand = this.biomarkerUpperBandValue;
    const biomarkerLowerBand = this.biomarkerLowerBandValue;

    // X-axis, biomaerker series, upper band and lower band series
    const labels = Object.keys(biomarkerMeasures);
    const biomarkerMeasuresSeries = Object.values(biomarkerMeasures);
    const biomarkerUpperBandSeries = Object.values(biomarkerUpperBand);
    const biomarkerLowerBandSeries = Object.values(biomarkerLowerBand);

    // Defining chart Y range constants
    const biomarkerHighest = Math.max(...biomarkerMeasuresSeries);
    const highestUpperBandY = Math.max(...biomarkerUpperBandSeries);
    const highestYValue = Math.max(biomarkerHighest, highestUpperBandY);
    const biomarkerLowest = Math.min(...biomarkerMeasuresSeries);
    const lowestLowerBandY = Math.min(...biomarkerUpperBandSeries);
    const axisStartYValue = 0;

    // debugger
    // Add two placeholder labels to center the point
    labels.unshift(""); // Add an empty label at the beginning
    labels.push("");     // Add an empty label at the end

    // Add placeholder null values to maintain dataset length
    biomarkerMeasuresSeries.unshift(null); // Empty value at the beginning
    biomarkerMeasuresSeries.push(null);    // Empty value at the end

    // Repeat band values for placeholder
    biomarkerUpperBandSeries.unshift(biomarkerUpperBandSeries[0]);
    biomarkerUpperBandSeries.push(biomarkerUpperBandSeries[biomarkerUpperBandSeries.length-1]);
    biomarkerLowerBandSeries.unshift(biomarkerLowerBandSeries[0]);
    biomarkerLowerBandSeries.push(biomarkerLowerBandSeries[biomarkerLowerBandSeries.length-1]);

    //
     const pointColor = (context) => {
      // value extracts a specific data point from the chart dataset based on the current context
      // in which the function pointColor is being called.
      const value = context.dataset.data[context.dataIndex];
      const upperBandY = biomarkerUpperBandSeries[context.dataIndex];
      const lowerBandY = biomarkerLowerBandSeries[context.dataIndex];

          if (value > upperBandY) {
            return '#E7EE33'
          } else if (value < lowerBandY) {
            return '#E7EE33'
          } else {
            return '#044E0C'
          }
    };

    // Helper function to calculate step size
    function calculateStepSize(min, max) {
      const range = max - min;
      if (range <= 1) return 0.2;
      if (range <= 3) return 0.6;
      if (range <= 5) return 1;
      if (range <= 10) return 2;
      if (range <= 20) return 4;
      if (range <= 40) return 8;
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

    // Define afterDatasetsDraw plugin hook to ensure the points of the Biomarker measures series are drawn last
    // Normally, Chart.js renders datasets (lines and points) together,
    // which can cause overlapping issues. By using a plugin, we separate the rendering of points from the lines, ensuring they are drawn last.
    const ensurePointsOnTop = {
      id: 'ensurePointsOnTop',
      afterDatasetsDraw(chart, args, options) {
        const ctx = chart.ctx;
        //retrieves the metadata for the Biomarker measures dataset, including the points.
        const biomarkerDatasetIndex = chart.data.datasets.findIndex(
          (dataset) => dataset.label === 'Biomarker measures'
        );

        if (biomarkerDatasetIndex !== -1) {
          const datasetMeta = chart.getDatasetMeta(biomarkerDatasetIndex);

          // Force re-rendering of the points for Biomarker measures
          datasetMeta.data.forEach((point) => {
            point.draw(ctx); // Redraw the points
          });
        }
      },
    };

    const data = {
      labels: labels,
        datasets: [
          {
            label: 'Lower band',
            data: biomarkerLowerBandSeries,
            fill: false, // Ensures the fill color spans from this dataset to the upper band
            borderColor: 'rgba(155, 238, 155, 0.3)',
            borderWidth: 2,
            tension: 0.1,
            pointRadius: 0,
            order: 1
          },
          {
          label: 'Upper band',
          data: biomarkerUpperBandSeries,
          backgroundColor: 'rgba(155, 238, 155, 0.1)',
          fill: '-1', // Fills to the previous dataset (lower band), creating the area in between -> The dataset order matters.
          borderColor: 'rgba(155, 238, 155, 0.3)',
          borderWidth: 2,
          tension: 0.1,
          pointRadius: 0,
          order: 2
        },
        {
          label: 'Biomarker measures',
          data: biomarkerMeasuresSeries, // Biomarker measures
          fill: false,
          borderColor: '#B9D7FA',
          tension: 0.1,
          pointRadius: 6,
          pointBorderWidth: 3,
          pointBorderColor: pointColor, // Chart.js will pass `context` to `pointColor` for each data point in the dataset
          pointBackgroundColor: pointColor, // Chart.js will pass `context` to `pointColor` for each data point in the dataset
          order: 3
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
          beginAtZero: true,
          max: Math.round(calculateStepSize(axisStartYValue, highestYValue)*6*100)/100, // Stepsize are range divided 5 -> 6 to add some pading.
          ticks: {
            // stepSize: Math.ceil((upperYAxis - lowerYAxis)/5),
            padding: window.innerWidth < 576 ? 5 : 30,
            display: true,
            font: {
              size: window.innerWidth < 576 ? 10 : 14,  // Reduce font size on small screens
            },
            stepSize: calculateStepSize(axisStartYValue, highestYValue),  // Custom step size
            callback: function(value) {
              if (value < 10) {
                return value.toFixed(1); // Format to 2 decimal places
              }
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


    // Initialize the chart
    new Chart(ctx, {
      type: 'line',  // or 'line', 'pie', etc.
      data: data,
      options: options,
      plugins: [ensurePointsOnTop]
    });
  }
}
