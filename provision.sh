#!/bin/bash -x

echo "RUNNING PROVISION"
echo
echo "CMD: build_rbbt_provision_sh.rb -ss -sr -sg -su -w Translation -rr Organism --nocolor --nobar"

echo "1. Provisioning base system"
echo SKIPPED
echo

echo "2. Setting up ruby"
echo SKIPPED
echo

echo "3. Setting up gems"
echo SKIPPED
echo

echo "4. Configuring user"
echo SKIPPED
echo

echo "5. Bootstrapping workflows as 'rbbt'"
echo

if [[ 'rbbt' == 'root' ]] ; then
  home_dir='/root'
else
  home_dir='/home/rbbt'
fi

user_script=$home_dir/.rbbt/bin/bootstrap

cat > $user_script <<'EUSER'

. /etc/profile

echo "5.1. Loading custom variables"
export RBBT_LOG="0"
export BOOTSTRAP_WORKFLOWS="Translation"
export REMOTE_RESOURCES="Organism"
export RBBT_NOCOLOR="true"
export RBBT_NO_PROGRESS="true"

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



echo "5.3. Configuring rbbt"
#!/bin/bash -x

# USER RBBT CONFIG
# ================

# File servers: to speed up the production of some resources
for resource in $REMOTE_RESOURCES; do
    echo "Adding remote file server: $resource -- $RBBT_FILE_SERVER"
    rbbt file_server add $resource $RBBT_FILE_SERVER
done

# Remote workflows: avoid costly cache generation
for workflow in $REMOTE_WORKFLOWS; do
    echo "Adding remote workflow: $workflow -- $RBBT_WORKFLOW_SERVER"
    rbbt workflow remote add $workflow $RBBT_WORKFLOW_SERVER
done

#
echo "5.4. Install and bootstrap"
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

apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo
echo "Installation done."
