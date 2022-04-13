#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

MODULE_DIR=${SCRIPT_DIR}/.terraform/modules/provider

if [[ ! -f ${MODULE_DIR}/variables.tf ]]; then
    echo -e "module \"provider\" {\n \
    source = \"${1}\"\n
  }\n" > ${SCRIPT_DIR}/provider_module.tf
    echo "provider has no variables file: ${MODULE_DIR}/variables.tf"
    exit 0;
fi

module='module "provider" {'
module="${module}\n  source = \"${1}\"\n"

VARIABLES_GLOBAL=$(cat ${MODULE_DIR}/variables_global.tf | egrep "^variable" | awk '{print $2}' | tr -d '"')
module="${module}\n  # modules from variables_global.tf\n"
for var in $VARIABLES_GLOBAL; do 
  module="${module}\n  ${var} = var.${var}"
done

VARIABLES=$(cat ${MODULE_DIR}/variables.tf | egrep "^variable" | awk '{print $2}' | tr -d '"')
module="${module}\n\n  # modules from variables.tf\n"
for var in $VARIABLES; do 
  module="${module}\n  ${var} = var.${var}"
done
module="${module}\n}\n"

echo -e "${module}" > ${SCRIPT_DIR}/provider_module.tf

cp ${MODULE_DIR}/provider.tf-orig ${SCRIPT_DIR}/provider.tf
cp ${MODULE_DIR}/variables.tf ${SCRIPT_DIR}/variables_imported.tf