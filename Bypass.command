clear
echo ''
echo ''
echo 'Copyright © Eric Larrode (https://github.com/neoalarrode)'
echo ''
echo ''

# Change the current working directory
cd "`dirname "$0"`"

# Comprobación de HomeBrew, si no esta presente lo instala
if test ! $(which brew); then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null 2>&1
    echo ''
fi

# Combrobacion de sshpass, lo instala si no lo encuentra
if test ! $(which sshpass); then
    echo "Installing sshpass..."
    brew install esolitos/ipa/sshpass > /dev/null 2>&1
    echo ''
fi

# Comprobacion de iproxy, si no lo instala
if test ! $(which iproxy); then
    echo "Installing iproxy..."
    brew install libimobiledevice > /dev/null 2>&1
    echo ''
fi

echo 'Primero debes de Ejecutar el exploit de Checkra1n, suedes descargarlo desde https://checkra.in'
read -p 'Press enter when you finish'

echo ''

echo 'Continua la configuración del iPhone hasta la selección de redes WiFi, no te conectes a ninguna, selecciona la acción de conectar a iTunes'
read -p 'Press enter to continue'

echo ''

echo 'Iniciando iProxy...'

# Ejecutando iProxy en segundo plano
iproxy 2222:44 > /dev/null 2>&1 &

sleep 2

while true ; do
  result=$(ssh -p 2222 -o BatchMode=yes -o ConnectTimeout=1 root@localhost echo ok 2>&1 | grep Connection)

  if [ -z "$result" ] ; then

echo '(1/7) Montando FileSystem en RW'
sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost -p 2222 mount -o rw,union,update / > /dev/null 2>&1

echo '(2/7) Desactivando original mobileactivationd'
sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost -p 2222 launchctl unload /System/Library/LaunchDaemons/com.apple.mobileactivationd.plist > /dev/null 2>&1

sleep 2

echo '(3/7) Eliminando original mobileactivationd'
sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost -p 2222 rm /usr/libexec/mobileactivationd > /dev/null 2>&1

echo '(4/7) Ejecutando uicache (Esto puede durar unos segundos)'
sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost -p 2222 uicache --all > /dev/null 2>&1

sleep 2

echo '(5/7) Copiando la version parcheada de mobileactivationd'
sshpass -p 'alpine' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P 2222 mobileactivationd_12_5_1_patched root@localhost:/usr/libexec/mobileactivationd > /dev/null 2>&1

echo '(6/7) Ajustando los permisos del parche de mobileactivationd'
sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost -p 2222 chmod 755 /usr/libexec/mobileactivationd > /dev/null 2>&1

echo '(7/7) Iniciando parche de mobileactivationd'
sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost -p 2222 launchctl load /System/Library/LaunchDaemons/com.apple.mobileactivationd.plist > /dev/null 2>&1

sleep 2

# Desactivando el iProxy
kill %1 > /dev/null 2>&1

echo 'Done!'

echo ''

echo 'El Bypass se ha completado con éxito, ya debería de haber pasado automaticamente la pantalla del iPhone, recuerda que se ha de ejecutar este procedimiento cada vez que se reinicio el iDevice'
echo ''
read -p 'Presiona Enter para finalizer'

    break

  fi

  echo 'Waiting for USB connection...'

  sleep 1

done
