#target photoshop
app.preferences.rulerUnits = Units.PIXELS;

var doc = activeDocument
doc.resizeCanvas(Math.max(doc.width,doc.height),Math.max(doc.width,doc.height))
