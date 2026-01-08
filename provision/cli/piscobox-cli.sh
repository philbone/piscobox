#!/bin/bash

# ============================================
# PISCOBOX-CLI COMMAND LINE TOOL
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

# Display header
#print_header "PISCOBOX CLI"
#echo "Start at: $SCRIPT_START_TIME"
#echo ""

case "$1" in
--help | -h | "")
  echo "PiscoBox-CLI 7 January 2026, by Philbone."
  echo ""
  echo "install         piscobox installation assistant"
  echo "  demo-php      install the PHP demos"
  echo "  demo-python   install the Python demos(soon)"  
  echo ""
  echo "uninstall       piscobox uninstallation assistant"
  echo "  demo-php      uninstall the PHP demos"
  echo "  demo-python   uninstall the Python demos(soon)"
  echo ""
  echo "mysql           piscobox mysql assistant"
  echo "  login         get instant access as piscoboxuser"
  ;;
mysql | mariadb)
  case "$2" in
  login)
    mysql -u piscoboxuser -pDevPassword123
    ;;
  esac
  ;;
install)
  case "$2" in 
  demo-php)
    #saludar    
    print_header "· PISCOBOX PHP DEMO INSTALLER ·"
    #solicitar confirmación, descomprimir demos en un directorio temporal, mover demos a public_html/piscoweb/demos/php, despedir y mostrar la salida."
    print_warning "The installation will take place in public_html/piscoweb/demos..."
    print_warning "The 'videogames' table will be created in the 'piscoboxdb' database"
    echo -n "Do you want to proceed with the installation? Y/n: "
    read rs;
    if [[ $rs == "y" || $rs == "Y" || $rs == "yes" || $rs == "YES" || $rs == "s" || $rs == "si" || $rs == "sí" || $rs == "SI" || $rs == "SÍ" ]]; then
      # instalado DEMOS PHP
      print_success "installing PHP demos...❯❯❯❯"
      rm -rf /var/tmp/demos/      
      mkdir -p /var/tmp/demos/php

      print_step 1 3 "📦 Unpacking PHP demo"
      unzip /vagrant/provision/files/demos/demo-php.zip -d /var/tmp/demos/php
      if [ $? -eq 0 ];then
        print_success "PHP demo unpacking to /var/tmp"
      fi

      print_step 2 3 "📝 Creating the necessary tables..."
      mysql -u piscoboxuser -pDevPassword123 piscoboxdb < /var/tmp/demos/php/create_gamevault.sql
      if [ $? -eq 0 ];then
        print_success "Tables created"        
      fi

      print_step 3 3 "🗂️ Creating the destination directory and moving the files"
      sudo mkdir -p /var/www/html/piscoweb/demos/
      sudo mv /var/tmp/demos/php/*.php /var/www/html/piscoweb/demos/
      sudo mv /var/tmp/demos/php/demos.json /var/www/html/piscoweb/demos/
      if [ $? -eq 0 ];then        
        print_success "demos php instalados en public_html/piscoweb/demos/ 🥂"
        rm -r /var/tmp/demos/
      fi

    else
      print_error "The demos will not be installed 😭"
    fi    
    # mysql -u piscoboxuser -pDevPassword123 piscoboxdb < /vagrant/provision/files/create_gamevault.sql
    ;;
  demo-python)
    print_warning "🚧 Python demo not yet implemented 🚧"
    ;;
  esac    
  ;;
uninstall)
  case "$2" in 
    demo-php)
      print_header "· PISCOBOX PHP DEMO UNINSTALLER ·"      
      print_warning "The PHP files in public_html/piscoweb/demos will be ERASED"
      print_warning "The 'videogames' table will be DELETED from 'piscoboxdb' database"
      echo -n "Do you want to proceed with the delete process? Y/n: "
      read rs;
      if [[ $rs == "y" || $rs == "Y" || $rs == "yes" || $rs == "YES" || $rs == "s" || $rs == "si" || $rs == "sí" || $rs == "SI" || $rs == "SÍ" ]]; then
        print_success "Uninstall PHP demos...❯❯❯❯"
        
        print_step 1 3 "Deleting the database tables 🗑"
        mysql -u piscoboxuser -pDevPassword123 -D piscoboxdb -e 'DROP TABLE IF EXISTS videogames;'

        print_step 2 3 "Removing all PHP files from the demos directory 🗑️"
        sudo rm -rf /var/www/html/piscoweb/demos/*.php
        sudo rm -rf /var/www/html/piscoweb/demos/demos.json

        if [ -z "$( ls -A '/var/www/html/piscoweb/demos/' )" ]; then        
          print_step 3 3 "Removing the empty demos directory 🗑️"
          sudo rm -rf /var/www/html/piscoweb/demos/
        else
           echo "Not Empty"
        fi
      else
        echo "uninstall Canceled"
      fi
    ;;
    demo-python)
      echo "uninstall Python demo"
  esac
  ;;
*)
  print_error "⚠️ Unknown command: $1"
  ;;
esac
