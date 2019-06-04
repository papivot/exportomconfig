#!/bin/bash

OM_TARGET='opsman.domain.com'
OM_USERNAME='admin'
OM_PASSWORD='password'

if command -v jq >/dev/null 2>&1
then
#        echo "Command jq found in PATH. Proceeding..."
        :
else
        echo "Command JQ not found in PATH. Please install JQ and try again. Exiting..."
        exit 1
fi

if command -v om >/dev/null 2>&1
then
#        echo "Command om found in PATH. Proceeding..."
        :
else
        echo "Command OM not found in PATH. Please install OM and try again. Exiting..."
        exit 1
fi

mkdir -p ${OM_TARGET}

om -t ${OM_TARGET} -u ${OM_USERNAME} -p ${OM_PASSWORD} -k deployed-products -f json |jq -cr '.[]' > ${OM_TARGET}/products.txt
om -t ${OM_TARGET} -u ${OM_USERNAME} -p ${OM_PASSWORD} -k staged-director-config --no-redact  > ${OM_TARGET}/stagedconfig-director.yml
for product in $(om -t ${OM_TARGET} -u ${OM_USERNAME} -p ${OM_PASSWORD} -k deployed-products -f json |jq -cr '.[]')
do
	productname=`echo $product|jq -r '.name'`
	echo "Exporting config for product - ${productname} "
	om -t ${OM_TARGET} -u ${OM_USERNAME} -p ${OM_PASSWORD} -k staged-config -p ${productname} -c    > ${OM_TARGET}/stagedconfig-${productname}.yml
	om -t ${OM_TARGET} -u ${OM_USERNAME} -p ${OM_PASSWORD} -k staged-config -p ${productname} -c -r > ${OM_TARGET}/sampleconfig-${productname}.yml
done
