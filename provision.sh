#!/bin/bash -x

echo "RUNNING PROVISION"
echo
echo "CMD: git/rbbt-image/bin/build_rbbt_provision_sh.rb -ss -sr -sg -su -w Translation -rr Organism"

echo "1. Provisioning base system"
echo
echo SKIPPED

echo "2. Setting up ruby"
echo
echo SKIPPED

echo "3. Setting up gems"
echo
echo SKIPPED

echo "4. Configuring user"
echo
echo SKIPPED

echo "5. Bootstrapping workflows as 'rbbt'"
echo
user_script=$home_dir/.rbbt/bin/bootstrap

cat > $user_script <<'EUSER'

. /etc/profile

echo "5.1. Loading custom variables"
export RBBT_LOG="0"
export BOOTSTRAP_WORKFLOWS="Translation"
export REMOTE_RESOURCES="Organism"

echo "5.2. Loading default variables"
#!/bin/bash -x

test -z ${RBBT_SERVER+x}           && RBBT_SERVER=http://rbbt.bioinfo.cnio.es/ 
test -z ${RBBT_FILE_SERVER+x}      && RBBT_FILE_SERVER="$RBBT_SERVER"
test -z ${RBBT_WORKFLOW_SERVER+x}  && RBBT_WORKFLOW_SERVER="$RBBT_SERVER"

test -z ${REMOTE_RESOURCES+x}  && REMOTE_RESOURCES="Organism ICGC COSMIC KEGG InterPro"
test -z ${REMOTE_WORFLOWS+x}   && REMOTE_WORFLOWS=""

test -z ${RBBT_WORKFLOW_AUTOINSTALL+x}  && RBBT_WORKFLOW_AUTOINSTALL="true"

test -z ${WORKFLOWS+x}  && WORKFLOWS=""

test -z ${BOOTSTRAP_WORKFLOWS+x}  && BOOTSTRAP_WORKFLOWS=""
test -z ${BOOTSTRAP_CPUS+x}       && BOOTSTRAP_CPUS="2"

test -z ${RBBT_LOG+x}  && RBBT_LOG="LOW"



echo "5.3. Install and bootstrap"
#!/bin/bash -x

# USER RBBT BOOTSTRAP
# ===================

for workflow in $WORKFLOWS; do
    rbbt workflow install $workflow 
done

export RBBT_WORKFLOW_AUTOINSTALL
export RBBT_LOG

for workflow in $BOOTSTRAP_WORKFLOWS; do
    echo "Bootstrapping $workflow on $BOOTSTRAP_CPUS CPUs"
    rbbt workflow cmd $workflow bootstrap $BOOTSTRAP_CPUS
done

EUSER

chown rbbt $user_script;
su -l -c "bash $user_script" rbbt

# CODA
# ====

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo
echo "Installation done."
