MySQL Installation and Setup

Step 1: Download MySQL

Go to the MySQL download page.

Choose the version of MySQL for your operating system.

Download the installer (e.g., MySQL Installer for Windows).

Step 2: Install MySQL

Run the MySQL Installer.

Follow the installation wizard's instructions.

Choose the default setup options unless you need something custom.

During installation, you'll be prompted to set the root password. Choose a secure password and keep it in a safe place.

Step 3: Start MySQL Server

Once the installation is complete, open the MySQL Workbench or Command Line Client.

Connect to the MySQL server using the root username and password you set earlier.

Step 4: Configure MySQL (if necessary)

Ensure local_infile is enabled to allow loading CSV files. You can do this by adding the following to the MySQL configuration file (my.cnf or my.ini):

local_infile=1

Step 5: Test MySQL

Open MySQL Workbench or Command Line Client.

Run the following command to ensure everything is working:

SELECT VERSION();