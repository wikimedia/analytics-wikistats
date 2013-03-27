
/* 
 * This function will deal with unsampling the data.
 * The logs inside the squid server are sampled 1:1000
 * 
 * Afterwards, if the number is truncated and added M and k as
 * the case may be.
 *
 */

(function(window) {

  var UNSAMPLING_FACTOR = 1000;
  var RELEVANT_DECIMALS = 1   ;
  var MILLION           = 1000000;
  var THOUSAND          = 1000;

  function unsample_and_format(val) {
    val *= UNSAMPLING_FACTOR;
    if(        val >= MILLION ) {
      val /= MILLION;
      var num = parseFloat(val);
      val     = num.toFixed(RELEVANT_DECIMALS);
      if(val == Math.floor(val)) {
        val = Math.floor(val);
      };
      val += " M";
    } else if( val >= THOUSAND    ) {
      val /= THOUSAND;
      var num = parseFloat(val);
      val     = num.toFixed(RELEVANT_DECIMALS);
      if(val == Math.floor(val)) {
        val = Math.floor(val);
      };
      val += " k";
    };

    return val;
  };

  window.unsample_and_format = unsample_and_format;
})(window);

