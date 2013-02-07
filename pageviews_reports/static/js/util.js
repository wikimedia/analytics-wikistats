

function tdc(bgc,perc,val,idObserved,idContainer)
{ 
  var strId1 = " ";
  var strId2 = " ";
  if(idObserved) {
    strId1 = ' id="' + idObserved  +'" ';
  };
  if(idContainer) {
    strId2 = ' id="' + idContainer +'" ';
  };
  document.write(
    "<td" + strId1 + "bgcolor=\"" + bgc + "\"><span class=d1>"+
    perc  + "</span><small><br></small><span class=d2>"+
    val   + "</span></td>"
  );
  document.write('<div id="'+strId2+'"></div>');
}	 

