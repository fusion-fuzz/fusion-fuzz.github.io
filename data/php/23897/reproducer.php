<?php
try {
try {
$dom = new \DOMDocument();
$rootNode = $dom->appendChild($dom->createElement('root'));
for ($i = 0; $i <= 100; $i++) {
$level1Node = $rootNode->appendChild($dom->createElement('level1'));
}
$xslStr = <<<EOF
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl">
<xsl:template match="root">
<output>
<xsl:for-each select="level1">
<node>
<xsl:value-of select="php:function('testPhpFunction', .)" />
</node>
</xsl:for-each>
</output>
</xsl:template>
</xsl:stylesheet>
EOF;
$xsl = new \DOMDocument();
$xsl->loadXML($xslStr);
$xslt = new \XSLTProcessor();
$xslt->registerPHPFunctions('testPhpFunction');
} catch (\Throwable $_ffl_e) {}
try {
$xslt->importStyleSheet($xsl);
echo $xslt->transformToXML($dom);
} catch (\Throwable $_ffl_e) {}
} catch (\Throwable $_ffl_e) {}
