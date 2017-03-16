(function(global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  function stringContains(needle) {
    return function (haystack) {
      return haystack.toLowerCase().indexOf(needle.toLowerCase()) !== -1;
    }
  }

  GOVUK.chooseACountry = {
    attach: function () {
      var countries = $('#js-disabled-country-picker')
        .find('option')
        .toArray()
        .map(function (element) { return [element.value, $(element).text()]; })
        .filter(function (value) { return !!value[0]; });

      function suggest(query, syncResults) {
        syncResults(query ? countries.map(function(x) { return x[1] } ).filter(stringContains(query)) : [])
      }

      var countryPickerElement = $('#country-picker').get(0);
      window.AccessibleTypeahead({
        element: countryPickerElement,
        source: suggest
      });

      $('form').submit(function () {
        // TODO: look up the country code by its text
      })
    }
  };

  global.GOVUK = GOVUK;
})(window);