<?php
$rc=new reflectionClass('domDocument');
$fusion = $rc;
foreach ($fusion->getProperties() as $rp) {
var_dump($rp->isWritable(null));
}
