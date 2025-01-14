::Script by Shadow256
call tools\storage\functions\ini_scripts.bat
Setlocal enabledelayedexpansion
set this_script_full_path=%~0
set associed_language_script=%language_path%\!this_script_full_path:%ushs_base_path%=!
set associed_language_script=%ushs_base_path%%associed_language_script%
IF NOT EXIST "%associed_language_script%" (
	set associed_language_script=languages\FR_fr\!this_script_full_path:%ushs_base_path%=!
	set associed_language_script=%ushs_base_path%!associed_language_script!
	echo The associated language file cannot be found, please run the updater to download it. French will be set as default.
	pause
)
IF NOT EXIST "%associed_language_script%" (
	echo Language error. Please use the update manager to update the script. This script will now close.
	pause
	endlocal
	goto:eof
)
IF EXIST "%~0.version" (
	set /p this_script_version=<"%~0.version"
) else (
	set this_script_version=1.00.00
)
call "%associed_language_script%" "display_title"
IF EXIST "templogs" (
	del /q "templogs" 2>nul
	rmdir /s /q "templogs" 2>nul
)
mkdir "templogs"
set keys_file_path=
IF EXIST "update_packages\*.*" rmdir /s /q "update_packages"
IF EXIST "firmware_temp\*.*" rmdir /s /q "firmware_temp" 2>nul
call "%associed_language_script%" "intro"
IF %errorlevel% EQU 2 goto:endscript2
call "%associed_language_script%" "intro_2"
IF %errorlevel% EQU 1 start tools\drivers\automatic_install\drivers.exe
echo.
call "%associed_language_script%" "patched_console_choice"
IF %errorlevel% EQU 1 (
	set patched_console=O
	set method_creation_firmware_unbrick_choice=2
)
IF %errorlevel% EQU 2 (
	set patched_console=N
	set mariko_console=N
)
IF /i "%patched_console%"=="O" (
	call "%associed_language_script%" "mariko_console_choice"
	IF !errorlevel! EQU 1 (
		set mariko_console=O
		goto:keys_file_creation
	) else (
		set mariko_console=N
	)
)

echo.
call "%associed_language_script%" "dump_keys_choice"
IF %errorlevel% EQU 1 (
	call "%associed_language_script%" "dump_keys_instructions_begin"
	IF /i NOT "%patched_console%"=="O" tools\TegraRcmSmash\TegraRcmSmash.exe -w "tools\payloads\Lockpick_RCM.bin"
	call "%associed_language_script%" "dump_keys_instructions_end"
	IF !errorlevel! EQU 2 goto:endscript2
)

	IF /i "%mariko_console%"=="O" goto:keys_file_creation

call "%associed_language_script%" "method_creation_firmware_unbrick_choice"
if "%errorlevel%"=="1" (
	set method_creation_firmware_unbrick_choice=1
) else if "%errorlevel%"=="2" (
	set method_creation_firmware_unbrick_choice=2
	goto:keys_file_creation
) else (
	goto:endscript2
)

if "%method_creation_firmware_unbrick_choice%"=="1" (
	IF EXIST tools\Hactool_based_programs\keys.txt (
		call "%associed_language_script%" "define_new_keys_file_choice"
		IF !errorlevel! equ 1 (
			set define_new_keys_file=o
			goto:keys_file_creation
		)
	)
	IF NOT EXIST tools\Hactool_based_programs\keys.txt (
		IF EXIST tools\Hactool_based_programs\keys.dat (
			rename tools\Hactool_based_programs\keys.dat keys.txt >nul
			goto:skip_keys_file_creation
		)
		call "%associed_language_script%" "keys_file_not_finded"
		goto:keys_file_creation
	) else (
		goto:skip_keys_file_creation
	)
)
:keys_file_creation
echo.
call "%associed_language_script%" "keys_file_selection"
set /p keys_file_path=<"templogs\tempvar.txt"
IF "%keys_file_path%"=="" (
	call "%associed_language_script%" "no_keys_file_selected_error"
	goto:endscript
)
if "%method_creation_firmware_unbrick_choice%"=="1" (
	copy "%keys_file_path%" "tools\Hactool_based_programs\keys.txt" >nul
)
:skip_keys_file_creation
if "%method_creation_firmware_unbrick_choice%"=="1" (
	IF EXIST tools\Hactool_based_programs\ChoiDuJour_keys.txt del /q tools\Hactool_based_programs\ChoiDuJour_keys.txt >nul
	cd tools\Hactool_based_programs
	..\python3_scripts\Keys_management\keys_management.exe create_choidujour_keys_file ..\Hactool_based_programs\keys.txt >..\..\templogs\result_choidujour_keys_file_creation_file.txt
	cd ..\..
	tools\gnuwin32\bin\tail.exe -n1 <"templogs\result_choidujour_keys_file_creation_file.txt" >templogs\tempvar.txt
	set /p create_choidujour_keys_file=<templogs\tempvar.txt
	echo !create_choidujour_keys_file! | tools\gnuwin32\bin\grep.exe -c "ChoiDuJour_keys.txt" >templogs\tempvar.txt
	set /p temp_count=<templogs\tempvar.txt
	IF "!temp_count!"=="1" (
		set create_choidujour_keys_file_state=0
		goto:skip_choidujour_keys_file_create
	)
	echo !create_choidujour_keys_file! | tools\gnuwin32\bin\grep.exe -c " obligatoire " >templogs\tempvar.txt
	set /p temp_count=<templogs\tempvar.txt
	IF "!temp_count!"=="1" (
		set create_choidujour_keys_file_state=1
		echo !create_choidujour_keys_file! | tools\gnuwin32\bin\cut.exe -d \^" -f 2 >templogs\tempvar.txt
		set /p key_missing=<templogs\tempvar.txt
		del /q tools\Hactool_based_programs\keys.txt >nul
		goto:skip_choidujour_keys_file_create
	)
	echo !create_choidujour_keys_file! | tools\gnuwin32\bin\grep.exe -c " facultative " >templogs\tempvar.txt
set /p temp_count=<templogs\tempvar.txt
	IF "!temp_count!"=="1" (
		set create_choidujour_keys_file_state=2
		echo !create_choidujour_keys_file! | tools\gnuwin32\bin\cut.exe -d \^" -f 2 >templogs\tempvar.txt
		set /p key_missing=<templogs\tempvar.txt
		goto:skip_choidujour_keys_file_create
	)
)
:skip_choidujour_keys_file_create
if "%method_creation_firmware_unbrick_choice%"=="1" (
	call "%associed_language_script%" "choidujour_keys_file_creation"
	IF NOT EXIST tools\Hactool_based_programs\ChoiDuJour_keys.txt (
		call "%associed_language_script%" "choidujour_keys_file_create_error"
		goto:endscript
	)
	IF EXIST "downloads\ChoiDuJour_package_6.1.0.zip" del /q "downloads\ChoiDuJour_package_6.1.0.zip" >nul
	IF EXIST "downloads\ChoiDuJour_package_5.1.0.zip" (
		TOOLS\7zip\7za.exe x -y -sccUTF-8 "downloads\ChoiDuJour_package_5.1.0.zip" -o"." -r
		IF !errorlevel! NEQ 0 (
			call "%associed_language_script%" "extract_error"
			goto:endscript
		)
	)
)
:internet_connection_verif
echo.
ping /n 2 www.google.com >nul 2>&1
IF %errorlevel% NEQ 0 (
	call "%associed_language_script%" "no_internet_connection_error"
	goto:endscript
)

if "%keys_file_path%"=="" set keys_file_path=tools\Hactool_based_programs\keys.txt
:define_volume_letter
%windir%\system32\wscript //Nologo //B TOOLS\Storage\functions\list_volumes.vbs
TOOLS\gnuwin32\bin\grep.exe -c "" <templogs\volumes_list.txt >templogs\count.txt
set /p tempcount=<templogs\count.txt
del /q templogs\count.txt
IF "%tempcount%"=="0" (
	call "%associed_language_script%" "no_disk_found_error"
	IF !errorlevel! EQU 1 (
		goto:define_volume_letter
	) else IF !errorlevel! EQU 2 (
		goto:endscript2
	)
)
echo.
call "%associed_language_script%" "disk_list_begin"
:list_volumes
IF "%tempcount%"=="0" goto:set_volume_letter
TOOLS\gnuwin32\bin\tail.exe -%tempcount% <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\head.exe -1
set /a tempcount-=1
goto:list_volumes
:set_volume_letter
echo.
echo.
set volume_letter=
call "%associed_language_script%" "disk_choice"
call TOOLS\Storage\functions\strlen.bat nb "%volume_letter%"
IF %nb% EQU 0 (
	call "%associed_language_script%" "disk_choice_empty_error"
	goto:define_volume_letter
)
set volume_letter=%volume_letter:~0,1%
IF "%volume_letter%"=="0" goto:endscript2
set nb=1
CALL TOOLS\Storage\functions\CONV_VAR_to_MAJ.bat volume_letter
set i=0
:check_chars_volume_letter
IF %i% LSS %nb% (
	set check_chars_volume_letter=0
	FOR %%z in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
		IF "!volume_letter:~%i%,1!"=="%%z" (
			set /a i+=1
			set check_chars_volume_letter=1
			goto:check_chars_volume_letter
		)
	)
	IF "!check_chars_volume_letter!"=="0" (
		call "%associed_language_script%" "disk_choice_char_error"
		goto:define_volume_letter
	)
)
IF NOT EXIST "%volume_letter%:\" (
	call "%associed_language_script%" "disk_choice_not_exist_error"
	goto:define_volume_letter
)
TOOLS\gnuwin32\bin\grep.exe "Lettre volume=%volume_letter%" <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\cut.exe -d ; -f 1 | TOOLS\gnuwin32\bin\cut.exe -d = -f 2 > templogs\tempvar.txt
set /p temp_volume_letter=<templogs\tempvar.txt
IF NOT "%volume_letter%"=="%temp_volume_letter%" (
	call "%associed_language_script%" "disk_choice_not_in_list_error"
	goto:define_volume_letter
)
set format_choice=
call "%associed_language_script%" "disk_format_choice"
IF %errorlevel% EQU 1 (
	set format_choice=o
	echo.
	set format_type=
	call "%associed_language_script%" "disk_format_type_choice"
) else (
	goto:copy_to_sd
)
IF %errorlevel% EQU 1 goto:format_exfat
IF %errorlevel% EQU 2 goto:format_fat32
set format_choice=
goto:copy_to_sd
:format_exfat
call "%associed_language_script%" "disk_formating_begin"
echo.
chcp 850 >nul
format %volume_letter%: /X /Q /FS:EXFAT
IF %errorlevel% NEQ 0 (
	chcp 65001 >nul
	call "%associed_language_script%" "disk_formating_error"
	goto:endscript
) else (
chcp 65001 >nul
	call "%associed_language_script%" "disk_formating_success"
	echo.
	goto:copy_to_sd
)
:format_fat32
call "%associed_language_script%" "disk_formating_begin"
echo.
TOOLS\fat32format\fat32format.exe -q -c128 %volume_letter%
echo.
IF "%ERRORLEVEL%"=="5" (
	call "%associed_language_script%" "disk_formating_fat32_not_admin_error"
	::echo.
	goto:copy_to_sd
)
IF "%ERRORLEVEL%"=="32" (
	call "%associed_language_script%" "disk_formating_fat32_disk_used_error"
	goto:endscript
)
IF "%ERRORLEVEL%"=="2" (
	call "%associed_language_script%" "disk_formating_fat32_disk_not_exist_error"
	goto:endscript
)
IF NOT "%ERRORLEVEL%"=="1" (
	IF NOT "%ERRORLEVEL%"=="0" (
		call "%associed_language_script%" "disk_formating_fat32_unknown_error"
		goto:endscript
	)
)
IF "%ERRORLEVEL%"=="1" (
	call "%associed_language_script%" "disk_formating_fat32_canceled_info"
)
IF "%ERRORLEVEL%"=="0" (
	call "%associed_language_script%" "disk_formating_success"
)
:copy_to_sd
set md5_try=0
IF NOT EXIST "downloads" mkdir "downloads"
IF NOT EXIST "downloads\firmwares" mkdir "downloads\firmwares"
IF EXIST "firmware_temp" (	
	del /q "firmware_temp" 2>nul
) else (
	mkdir firmware_temp
)
if "%method_creation_firmware_unbrick_choice%"=="1" (
	IF EXIST "downloads\ChoiDuJour_package_5.1.0.zip" goto:define_firmware_choice
	set expected_md5=656823850a70fb3050079423ee177c1a
	set "firmware_link=https://mega.nz/#^!8BplGRQA^!z_2pCeh-8XV2Pf3E_38UfGhDPRSdN3nixb5s5-Q785w"
	set firmware_file_name=Firmware 5.1.0.zip
	set firmware_folder=firmware_temp\
)
:download_firmware_choidujour
if "%method_creation_firmware_unbrick_choice%"=="1" (
	set md5_try=0
	IF EXIST "downloads\firmwares\%firmware_file_name%" goto:verif_md5sum_choidujour
)
:downloading_firmware_choidujour
if "%method_creation_firmware_unbrick_choice%"=="1" (
	IF NOT EXIST "downloads\firmwares\%firmware_file_name%" (
		call "%associed_language_script%" "firmware_downloading_begin"
	Setlocal disabledelayedexpansion
	TOOLS\megatools\megatools.exe dl --path="templogs\temp.zip" "%firmware_link%"
	endlocal
		TOOLS\gnuwin32\bin\md5sum.exe templogs\temp.zip | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
			set /p md5_verif=<templogs\tempvar.txt
	)
	IF NOT EXIST "downloads\firmwares\%firmware_file_name%" (
		IF NOT "!md5_verif!"=="%expected_md5%" (
			IF !md5_try! EQU 3 (
				call "%associed_language_script%" "firmware_downloading_md5_error"
				goto:endscript
			) else (
				call "%associed_language_script%" "firmware_downloading_md5_retry"
				set /a md5_try+=1
				goto:downloading_firmware_choidujour
			)
		)
	)
	set md5_try=0
	move "templogs\temp.zip" "downloads\firmwares\%firmware_file_name%" >nul
	goto:skip_verif_md5sum_choidujour
)
:verif_md5sum_choidujour
if "%method_creation_firmware_unbrick_choice%"=="1" (
	TOOLS\gnuwin32\bin\md5sum.exe "downloads\firmwares\%firmware_file_name%" | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
	set /p md5_verif=<templogs\tempvar.txt
IF NOT "!md5_verif!"=="%expected_md5%" (
		set md5_verif=
		call "%associed_language_script%" "firmware_exist_but_bad_md5_tested_error"
		goto:downloading_firmware_choidujour
	)
)
:skip_verif_md5sum_choidujour
if "%method_creation_firmware_unbrick_choice%"=="1" (
	call "%associed_language_script%" "firmware_downloading_end"
)
:define_firmware_choice
set optional_firmware_download=
if "%method_creation_firmware_unbrick_choice%"=="1" (
	echo.
	call "%associed_language_script%" "optional_firmware_download_choice"
	IF !errorlevel! EQU 2 goto:skip_optional_firmware_download
	IF !errorlevel! EQU 1 set optional_firmware_download=Y
)
set firmware_choice=
call "%associed_language_script%" "firmware_choice_begin"
echo 1.0.0?
echo 2.0.0?
echo 2.1.0?
echo 2.2.0?
echo 2.3.0?
echo 3.0.0?
echo 3.0.1?
echo 3.0.2?
echo 4.0.0?
echo 4.0.1?
echo 4.1.0?
echo 5.0.0?
echo 5.0.1?
echo 5.0.2?
echo 5.1.0?
echo 6.0.0?
echo 6.0.1?
echo 6.1.0?
echo 6.2.0?
echo 7.0.0?
echo 7.0.1?
echo 8.0.0?
echo 8.0.1?
echo 8.1.0?
echo 9.0.0?
echo 9.0.1?
echo 9.1.0?
echo 9.2.0?
echo 10.0.0?
echo 10.0.1?
echo 10.0.2?
echo 10.0.3?
echo 10.0.4?
echo 10.1.0?
echo 10.2.0?
echo 11.0.0?
echo 11.0.1?
echo 12.0.0?
echo 12.0.1?
echo 12.0.2?
echo 12.0.3?
echo 12.1.0?
echo 13.0.0?
echo 13.1.0?
echo.
call "%associed_language_script%" "firmware_choice_end"
IF "%firmware_choice%"=="1.0.0" (
	set expected_md5=46e6814359631d3c92bc43ead4328349
	set "firmware_link=https://mega.nz/#^!sVg2RKYS^!MVDYwOWwvL6rUKiXHPhDr7071MhsbTi9ybIn_RABihI"
	set firmware_file_name=Firmware 1.0.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="2.0.0" (
	set expected_md5=78fe09c2da202d35e58c7b07bb7f39a8
	set "firmware_link=https://mega.nz/#^!sAIzSQTK^!c1RNFqOrDt3-iW4Rn_M5IkUgx-ormrpImrtZXixNrOQ"
	set firmware_file_name=Firmware 2.0.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="2.1.0" (
	set expected_md5=35752c26badc270f9fdd51883922432b
	set "firmware_link=https://mega.nz/#^!gcx3UR5Y^!P4Ka3g4hum5c2tI0YwX8HBokm6SQ4EoCG2OeKtKC8dg"
	set firmware_file_name=Firmware 2.1.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="2.2.0" (
	set expected_md5=137f5d416d1b41ad26c35575dd534bc4
	set "firmware_link=https://mega.nz/#^!QVJl0aDA^!MU03vBUo1OXxK5Ha0yP04vli6W0LQjvZILuc_bh_Xq4"
	set firmware_file_name=Firmware 2.2.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="2.3.0" (
	set expected_md5=91e06f945e00e6412cc4ac44a0faa72b
	set "firmware_link=https://mega.nz/#^!1IxFgJBD^!kkliIMLOYNjmwIVR0tcr3svn72C6tMOQG5GHYie50q4"
	set firmware_file_name=Firmware 2.3.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="3.0.0" (
	set expected_md5=f4b5f8bffded14cca836bc24ecf19c06
	set "firmware_link=https://mega.nz/#^!RUxF3Lwb^!5fYRfHTFTx8KS9HnyYMmTuTTzKKQ4HyaQ4FqC-nyAc4"
	set firmware_file_name=Firmware 3.0.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="3.0.1" (
	set expected_md5=a245bc7d3151cd51687ce602a1d4dfbb
	set "firmware_link=https://mega.nz/#^!pE51RLgI^!pmvw4sfocWw-vZ26P3GjA2PSrLyeBcq-eunnvzmUx94"
	set firmware_file_name=Firmware 3.0.1.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="3.0.2" (
	set expected_md5=521e4aabc0b3b18d49f99c861cd55196
	set "firmware_link=https://mega.nz/#^!hNo1TLrL^!S1pfSuDaOoeW2eNcpe89bPP3BiW0b3pPqUrJvsVCAuQ"
	set firmware_file_name=Firmware 3.0.2.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="4.0.0" (
	set expected_md5=69ac6dbac1bd0a12ea9e12c97bc82907
	set "firmware_link=https://mega.nz/#^!EBIDFCrZ^!NaIuX7dvC3skUBAfb113qxhh0hJYzY3mm1mWou7Casc"
	set firmware_file_name=Firmware 4.0.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="4.0.1" (
	set expected_md5=3680ddfb0f7a2f01c83495dca909c757
	set "firmware_link=https://mega.nz/#^!NQg1yZaA^!4yuWJbXOGlCp6lryPcsF5ADEydk7jZq08RstUCDMKwY"
	set firmware_file_name=Firmware 4.0.1.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="4.1.0" (
	set expected_md5=fe53dd1eaa323bd9003f75a96822cb31
	set "firmware_link=https://mega.nz/#^!wQ4HGLgI^!ru3dBiMh9FdPJJvVTLJ6ex7EX0Rfma9Tw4J3gRWYU7k"
	set firmware_file_name=Firmware 4.1.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="5.0.0" (
	set expected_md5=de25e742c8c0fa9c7f6d079f65ddbf92
	set "firmware_link=https://mega.nz/#^!IBQlXQqL^!oePY4waKGpSnmVyxgXqEwx_vOeI6FvdBdpg0Wp4Y28c"
	set firmware_file_name=Firmware 5.0.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="5.0.1" (
	set expected_md5=79c2ac770eece2f9b713f3c6b12cc19a
	set "firmware_link=https://mega.nz/#^!BUB3TShb^!VFVqGrzK2j_6OIUTcbwzTvPCm8V5Aab2hXrdJrVmUqk"
	set firmware_file_name=Firmware 5.0.1.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="5.0.2" (
	set expected_md5=f14d2064255517aa1383e7e468e2ef19
	set "firmware_link=https://mega.nz/#^!wBwDCTgI^!7LsV9WSoYDBI6CamIBRzZYwA3wjCRchXyXw1VTTwXTc"
	set firmware_file_name=Firmware 5.0.2.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="5.1.0" (
	set expected_md5=656823850a70fb3050079423ee177c1a
	set "firmware_link=https://mega.nz/#^!8BplGRQA^!z_2pCeh-8XV2Pf3E_38UfGhDPRSdN3nixb5s5-Q785w"
	set firmware_file_name=Firmware 5.1.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="6.0.0" (
	set expected_md5=8e107ad46a5aacc1f8f5db7fc83d6945
	set "firmware_link=https://mega.nz/#^!0ZxlgABK^!HN8_ZfQHha-LaVr-95wUiotvGSObIUoEY8RxMwjDgVg"
	set firmware_file_name=Firmware 6.0.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="6.0.1" (
	set expected_md5=684f2184d9dd4bdc25ff161e0ea7353d
	set "firmware_link=https://mega.nz/#^!ZAYEhYSQ^!69L4mdQnPNKghHnMY41w3Di5MjvGXr8MhXGMVAxG5GA"
	set firmware_file_name=Firmware 6.0.1.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="6.1.0" (
	set expected_md5=320bd423e073a92b74dff30d92bcffa8
	set "firmware_link=https://mega.nz/#^!QAQ3ha4Y^!7fI6dJmhk3SUwyEl9cj9orRSE7Fjb1rghJxCnliXZRU"
	set firmware_file_name=Firmware 6.1.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="6.2.0" (
	set expected_md5=602826f8ad0ed04452a1092fc6d73c8c
	set "firmware_link=https://mega.nz/#^!9F5XFabb^!UdZmY8qpMbDuo-rrn0jI-JCpXrTWKoshKhClZ_H7tkA"
	set firmware_file_name=Firmware 6.2.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="7.0.0" (
	set expected_md5=550b0091304d54b67e3e977900c83dcc
	set "firmware_link=https://mega.nz/#^!kdJWQKBT^!G15TiWusLkrS7JT2KHNYXOfNAUOb2PWdhXsfe-kRtxg"
	set firmware_file_name=Firmware 7.0.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="7.0.1" (
	set expected_md5=c5440e557b8b62eabedf754e508ded2f
	set "firmware_link=https://mega.nz/#^!EERwCayT^!KPGACrRhEVQdhsaqbfqpNTwzAyRIoZRLvfqqmxhNT80"
	set firmware_file_name=Firmware 7.0.1.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="8.0.0" (
	set expected_md5=c0dab852378c289dc1fb135ed2a36f01
	set "firmware_link=https://mega.nz/#^!gU4B3KDa^!H5QKqthWmIAc5IM-pouiRFp-vOSkEfDTSMoSDFTUPps"
	set firmware_file_name=Firmware 8.0.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="8.0.1" (
	set expected_md5=c3a2a6ac6ef5956cdda6ce172ccd2053
	set "firmware_link=https://mega.nz/#^!lM4wSKCL^!_-38B-DFq9dqqUqu4EorS0hnBi099dY6JbkXYard51A"
	set firmware_file_name=Firmware 8.0.1.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="8.1.0" (
	set expected_md5=31c69ecb30326193afb141e1da8ff053
	set "firmware_link=https://mega.nz/#^!NQZnUKiJ^!IF9MawZaDgTWcszyu3zzuE4RRM1Kdo_4OKII93VBbQw"
	set firmware_file_name=Firmware 8.1.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="9.0.0" (
	set expected_md5=2e9d6fceed9f698a7625b1ea97986bde
	set "firmware_link=https://mega.nz/#^!sI5xyYqB^!3K1L3HsHmNkhvEoCiZvQp-GlUi9wUEx_9nU3wnuuOYY"
	set firmware_file_name=Firmware 9.0.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="9.0.1" (
	set expected_md5=f0a42373f582cc13b0b26cff09812714
	set "firmware_link=https://mega.nz/#^!4Z4BBIjR^!c8XwjWGeSQUTAuqk2d9ulK571_-BvRlItIv1Jx0S1so"
	set firmware_file_name=Firmware 9.0.1.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="9.1.0" (
	set expected_md5=9936bae12d9ada861a160a6a29c0b6dc
	set "firmware_link=https://mega.nz/#^!oJo2RCRb^!xMklUfjgiIXiDrCF4QLwtU0oQzMKqbVKbwuV4tGToY4"
	set firmware_file_name=Firmware 9.1.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="9.2.0" (
	set expected_md5=1a83c5642eb66acc44aa02fafa16b770
	set "firmware_link=https://mega.nz/#^!tRo0UahC^!Z5MntwPeB4Dv1643Q5novzsuZrhNQWxEND2sIzXg4aI"
	set firmware_file_name=Firmware 9.2.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="10.0.0" (
	set expected_md5=1b86a71fb9488bb2783a19d94f77e978
	set "firmware_link=https://mega.nz/file/wJplVTzS#49uqh5vyjgb8ZB_eZsmuQBk9ouRlHgwIQnd7MCwh1l8"
	set firmware_file_name=Firmware 10.0.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="10.0.1" (
	set expected_md5=946b52949dc35dab7a029adea14e99f8
	set "firmware_link=https://mega.nz/file/YRgBhB7b#gck6TCgkvaOL4rlTazJgkbALmTUCjg8fXmhTaaTOv-I"
	set firmware_file_name=Firmware 10.0.1.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="10.0.2" (
	set expected_md5=78702cba5d6024bc1c70870058b4dbb4
	set "firmware_link=https://mega.nz/file/kQBRnYzL#AxCTCgZf4kEjtUW5z1MUSSnlcwjEe6AptanmYtr1WN8"
	set firmware_file_name=Firmware 10.0.2.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="10.0.3" (
	set expected_md5=94d60ba229a00c16e11f2ea959a64123
	set "firmware_link=https://mega.nz/file/QRpGBI7C#UQZGw-FD8dfzIJg-Dw6PJeV0nFd8DNOQzZ5smriA32s"
	set firmware_file_name=Firmware 10.0.3.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="10.0.4" (
	set expected_md5=b39d012222fc5a9d236c9fa1c887b287
	set "firmware_link=https://mega.nz/file/FFRjyAwa#qeFAOzFjAecKVhaPTbZCKiajnVpYPplexG6X72vDO_0"
	set firmware_file_name=Firmware 10.0.4.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="10.1.0" (
	set expected_md5=ef4e13f1842b0a0472359d0d4de80145
	set "firmware_link=https://mega.nz/file/wQ4WBShJ#Tw7k2pCqB5IkkPPwFnwC7UAmQWvXzNs2-4D2Ldj267Q"
	set firmware_file_name=Firmware 10.1.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="10.2.0" (
	set expected_md5=8c18c4e5908178f9af4d8aad183b8ca2
	set "firmware_link=https://mega.nz/file/xF5g0SIB#4fa2DF0CC6sXB2a38l0bsA9ZZojL9HXVbIQeFLVzm3c"
	set firmware_file_name=Firmware 10.2.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="11.0.0" (
	set expected_md5=7330b3c560f80caeb2fa3d831d5203f2
	set "firmware_link=https://mega.nz/file/YRZjWSqC#D2IFvaI8t0mMQMbEZRIiNH5PPR5dOUx17IkhEYqhcfM"
	set firmware_file_name=Firmware 11.0.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="11.0.1" (
	set expected_md5=73200c7e53c864f06f648c121ee78677
	set "firmware_link=https://mega.nz/file/Yd5V0KgT#TYiu_F0Pmvqm758JHlqxivv9geMn7RQ7N2L4MCRo10g"
	set firmware_file_name=Firmware 11.0.1.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="12.0.0" (
	set expected_md5=d297bdb5a6d0341df6cc24195f604abe
	set "firmware_link=https://mega.nz/file/pJBCBLaC#rwCiDG9-ASH8K8cZYUUsg-UxHNqcmgsqcsmlRyyWmsY"
	set firmware_file_name=Firmware 12.0.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="12.0.1" (
	set expected_md5=12040ddd1533cf58ff2fb690d7bec3ee
	set "firmware_link=https://mega.nz/file/9UoUTYaY#l-rfPBQXpNIQ6I4UBeNRNHJhOE5zb5a7CPA4FAF_qJM"
	set firmware_file_name=Firmware 12.0.1.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="12.0.2" (
	set expected_md5=939ec032227741b60aafacbedc4e476f
	set "firmware_link=https://mega.nz/file/5IoTzABQ#Sjzs-_kOViyu1leE44Ae_YcloSa_FmgYRvUn9cXXcfk"
	set firmware_file_name=Firmware 12.0.2.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="12.0.3" (
	set expected_md5=26d79bde70476ab1c20ceefd8b0fd4c5
	set "firmware_link=https://mega.nz/file/lB5UTIqB#YSUkChTrftWSPJH7ulH537s9OgFWqrNr2OCEx7eGgSw"
	set firmware_file_name=Firmware 12.0.3.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="12.1.0" (
	set expected_md5=6c8f353daccf73e1da7ee5dd532656f0
	set "firmware_link=https://mega.nz/file/8cpWiR4K#Ina7VLZpVbfi53-9liXSYyes93VIga2BENiFqqAYYxU"
	set firmware_file_name=Firmware 12.1.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="13.0.0" (
	set expected_md5=9fa654de1a4682e517a15b5a79a7895d
	set "firmware_link=https://mega.nz/file/UFpi3Yra#_UwDAU0c0OrE88oInSHUXuhnwJwhPA2Qm297pbT7KSA"
	set firmware_file_name=Firmware 13.0.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
IF "%firmware_choice%"=="13.1.0" (
	set expected_md5=ab837980ed2c83eedaecb28ebf667d9a
	set "firmware_link=https://mega.nz/file/IFx1jIAZ#JZlMks0EjumXZEZPUgQhii_MjovVOzOLaxSP3_SHx8g"
	set firmware_file_name=Firmware 13.1.0.zip
	set firmware_folder=firmware_temp\
	goto:download_firmware
)
goto:endscript2

:download_firmware
set md5_try=0
IF EXIST "downloads\firmwares\%firmware_file_name%" goto:verif_md5sum
:downloading_firmware
IF NOT EXIST "downloads\firmwares\%firmware_file_name%" (
	call "%associed_language_script%" "firmware_downloading_begin"
Setlocal disabledelayedexpansion
TOOLS\megatools\megatools.exe dl --path="templogs\temp.zip" "%firmware_link%"
endlocal
	TOOLS\gnuwin32\bin\md5sum.exe templogs\temp.zip | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
		set /p md5_verif=<templogs\tempvar.txt
)
IF NOT EXIST "downloads\firmwares\%firmware_file_name%" (
	IF NOT "%md5_verif%"=="%expected_md5%" (
		IF %md5_try% EQU 3 (
			call "%associed_language_script%" "firmware_downloading_md5_error"
			goto:endscript
		) else (
			call "%associed_language_script%" "firmware_downloading_md5_retry"
			set /a md5_try+=1
			goto:downloading_firmware
		)
	)
)
set md5_try=0
move "templogs\temp.zip" "downloads\firmwares\%firmware_file_name%" >nul
goto:skip_verif_md5sum
:verif_md5sum
TOOLS\gnuwin32\bin\md5sum.exe "downloads\firmwares\%firmware_file_name%" | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
set /p md5_verif=<templogs\tempvar.txt
IF NOT "%md5_verif%"=="%expected_md5%" (
	set md5_verif=
	call "%associed_language_script%" "firmware_exist_but_bad_md5_tested_error"
	del /q "downloads\firmwares\%firmware_file_name%" >nul
	goto:downloading_firmware
)
:skip_verif_md5sum
call "%associed_language_script%" "firmware_downloading_end"

call "%associed_language_script%" "extract_firmware_begin"
TOOLS\7zip\7za.exe x -y -sccUTF-8 "downloads\firmwares\%firmware_file_name%" -o"firmware_temp" -r
IF %errorlevel% NEQ 0 (
	call "%associed_language_script%" "extract_error"
	goto:endscript
)
if "%method_creation_firmware_unbrick_choice%"=="1" (
	if exist "%volume_letter%:\FW_%firmware_choice%" rmdir /s /q "%volume_letter%:\FW_%firmware_choice%"
	%windir%\System32\Robocopy.exe firmware_temp %volume_letter%:\FW_%firmware_choice% /e >nul
	call :daybreak_convert "%volume_letter%:\FW_%firmware_choice%"
)
:skip_optional_firmware_download
if "%method_creation_firmware_unbrick_choice%"=="1" (
	IF EXIST "downloads\ChoiDuJour_package_5.1.0.zip" goto:copy_all_to_sd
	IF NOT "%firmware_choice%"=="5.1.0" (
		rmdir /s /q firmware_temp
		mkdir firmware_temp
		TOOLS\7zip\7za.exe x -y -sccUTF-8 "downloads\firmwares\Firmware 5.1.0.zip" -o"firmware_temp" -r
		IF !errorlevel! NEQ 0 (
			call "%associed_language_script%" "extract_error"
			goto:endscript
		)
	)
	set fspatches=--fspatches=nocmac,nogc
)
IF EXIST "update_packages" (
	del /q "update_packages" 2>nul
	rmdir /s /q "update_packages" 2>nul
)
mkdir "update_packages"
cd "update_packages"
if "%method_creation_firmware_unbrick_choice%"=="1" (
	"..\tools\Hactool_based_programs\tools\ChoiDujour.exe" --keyset="..\tools\Hactool_based_programs\ChoiDuJour_keys.txt" %fspatches% "..\firmware_temp"
	IF !errorlevel! EQU 0 (
		..\tools\7zip\7za.exe a -y -tzip -sccUTF-8 "..\downloads\ChoiDuJour_package_5.1.0".zip "..\update_packages" -r
		IF !errorlevel! NEQ 0 (
			call "%associed_language_script%" "create_choidujour_package_backup_warning"
			IF EXIST "..\downloads\ChoiDuJour_package_5.1.0.zip" del /q "..\downloads\ChoiDuJour_package_5.1.0.zip" >nul
			pause
		)
		call "%associed_language_script%" "package_creation_success"
	) else (
		call "%associed_language_script%" "package_creation_error"
		cd ..
		rmdir /s /q "firmware_temp"
		rmdir /s /q "update_packages"
		goto:endscript
	)
	cd ..
) else if "%method_creation_firmware_unbrick_choice%"=="2" (
	copy /v "..\tools\EmmcHaccGen\save.stub.v4" save.stub.v4 >nul
	copy /v "..\tools\EmmcHaccGen\save.stub.v5" save.stub.v5 >nul
	IF /i NOT "%mariko_console%"=="O" (
		"..\tools\EmmcHaccGen\EmmcHaccGen.exe" --keys "%keys_file_path%" --fw "..\firmware_temp"
	) else (
		"..\tools\EmmcHaccGen\EmmcHaccGen.exe" --keys "%keys_file_path%" --mariko --no-autorcm --fw "..\firmware_temp"
	)
	IF !errorlevel! EQU 0 (
		call "%associed_language_script%" "package_creation_success"
	) else (
		call "%associed_language_script%" "emmchaccgen_package_creation_first_error"
		if !errorlevel! EQU 1 (
			::Dism /online /NoRestart /Enable-Feature /FeatureName:"NetFx3"
			IF /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
				"..\tools\EmmcHaccGen\dotnet-runtime-3.1.12-win-x64.exe" /install /passive
			) else (
				"..\tools\EmmcHaccGen\dotnet-runtime-3.1.12-win-x86.exe" /install /passive
			)
			if !error_level! NEQ 0 (
				call "%associed_language_script%" "netfx3_install_error"
				cd ..
				rmdir /s /q "firmware_temp"
				rmdir /s /q "update_packages"
				goto:endscript
			) else (
				IF /i NOT "%mariko_console%"=="O" (
					"..\tools\EmmcHaccGen\EmmcHaccGen.exe" --keys "%keys_file_path%" --fw "..\firmware_temp"
				) else (
					"..\tools\EmmcHaccGen\EmmcHaccGen.exe" --keys "%keys_file_path%" --fw "..\firmware_temp" --mariko --no-autorcm
				)
				IF !errorlevel! EQU 0 (
					call "%associed_language_script%" "package_creation_success"
				) else (
					call "%associed_language_script%" "emmchaccgen_package_creation_second_error"
					cd ..
					rmdir /s /q "firmware_temp"
					rmdir /s /q "update_packages"
					goto:endscript
				)
			)
		) else (
			cd ..
			rmdir /s /q "firmware_temp"
			rmdir /s /q "update_packages"
			goto:endscript2
		)
	)
	del /q save.stub.v4 >nul
	del /q save.stub.v5 >nul
	cd ..
	dir /A:D /B update_packages >templogs\tempvar.txt
	set /p emmchaccgen_firmware_folder=<templogs\tempvar.txt
)
:copy_all_to_sd
rmdir /s /q firmware_temp
echo.
IF /i "%mariko_console%"=="O" goto:pass_boot0_creation
call "%associed_language_script%" "boot0_keyblobs_reparation_choice"
IF %errorlevel% EQU 3 goto:endscript2
IF %errorlevel% EQU 2 (
	if "%method_creation_firmware_unbrick_choice%"=="1" (
		copy "update_packages\NX-5.1.0_exfat\BOOT0.bin" "update_packages\NX-5.1.0_exfat\BOOT0.bin.bak" >nul
		IF !errorlevel! NEQ 0 (
			call "%associed_language_script%" "boot0_keyblobs_reparation_error"
			pause
		) else (
			"tools\python3_scripts\boot0_rewrite\boot0_rewrite.exe" -i "update_packages\NX-5.1.0_exfat\BOOT0.bin" -o "update_packages\NX-5.1.0_exfat\BOOT0.bin" -k "%keys_file_path%" >nul
			IF !errorlevel! NEQ 0 (
				call "%associed_language_script%" "boot0_keyblobs_reparation_first_error"
				if !errorlevel! EQU 2 (
				IF EXIST "update_packages\NX-5.1.0_exfat\BOOT0.bin" del /q "update_packages\NX-5.1.0_exfat\BOOT0.bin" >nul
					rename "update_packages\NX-5.1.0_exfat\BOOT0.bin.bak" "BOOT0.bin" >nul
					call "%associed_language_script%" "boot0_keyblobs_reparation_error"
					pause
					goto:pass_boot0_creation
				)
				set /p common_prod_keys_file=<templogs\tempvar.txt
				if "!common_prod_keys_file!"=="" (
					rename "update_packages\NX-5.1.0_exfat\BOOT0.bin.bak" "BOOT0.bin" >nul
					call "%associed_language_script%" "boot0_keyblobs_reparation_error"
					pause
					goto:pass_boot0_creation
				)
				"tools\python3_scripts\boot0_rewrite\boot0_rewrite.exe" -i "update_packages\NX-5.1.0_exfat\BOOT0.bin" -o "update_packages\NX-5.1.0_exfat\BOOT0.bin" -k "%keys_file_path%" -c "!common_prod_keys_file!" >nul
				IF !errorlevel! NEQ 0 (
					IF EXIST "update_packages\NX-5.1.0_exfat\BOOT0.bin" del /q "update_packages\NX-5.1.0_exfat\BOOT0.bin" >nul
					rename "update_packages\NX-5.1.0_exfat\BOOT0.bin.bak" "BOOT0.bin" >nul
					call "%associed_language_script%" "boot0_keyblobs_reparation_error"
					pause
					goto:pass_boot0_creation
				) else (
					del /q "update_packages\NX-5.1.0_exfat\BOOT0.bin.bak"
					call "%associed_language_script%" "boot0_keyblobs_reparation_success"
					pause
					goto:pass_boot0_creation
				)
			) else (
				del /q "update_packages\NX-5.1.0_exfat\BOOT0.bin.bak"
				call "%associed_language_script%" "boot0_keyblobs_reparation_success"
				pause
				goto:pass_boot0_creation
			)
		)
	) else if "%method_creation_firmware_unbrick_choice%"=="2" (
		copy "update_packages\%emmchaccgen_firmware_folder%\BOOT0.bin" "update_packages\%emmchaccgen_firmware_folder%\BOOT0.bin.bak" >nul
		IF !errorlevel! NEQ 0 (
			call "%associed_language_script%" "boot0_keyblobs_reparation_error"
			pause
		) else (
			"tools\python3_scripts\boot0_rewrite\boot0_rewrite.exe" -i "update_packages\%emmchaccgen_firmware_folder%\BOOT0.bin" -o "update_packages\%emmchaccgen_firmware_folder%\BOOT0.bin" -k "%keys_file_path%" >nul
			IF !errorlevel! NEQ 0 (
				call "%associed_language_script%" "boot0_keyblobs_reparation_first_error"
				if !errorlevel! EQU 2 (
					rename "update_packages\%emmchaccgen_firmware_folder%\BOOT0.bin.bak" "BOOT0.bin" >nul
					call "%associed_language_script%" "boot0_keyblobs_reparation_error"
					pause
					goto:pass_boot0_creation
				)
				set /p common_prod_keys_file=<templogs\tempvar.txt
				if "!common_prod_keys_file!"=="" (
					rename "update_packages\%emmchaccgen_firmware_folder%\BOOT0.bin.bak" "BOOT0.bin" >nul
					call "%associed_language_script%" "boot0_keyblobs_reparation_error"
					pause
					goto:pass_boot0_creation
				)
				"tools\python3_scripts\boot0_rewrite\boot0_rewrite.exe" -i "update_packages\%emmchaccgen_firmware_folder%\BOOT0.bin" -o "update_packages\%emmchaccgen_firmware_folder%\BOOT0.bin" -k "%keys_file_path%" -c "!common_prod_keys_file!" >nul
				IF !errorlevel! NEQ 0 (
					IF EXIST "update_packages\%emmchaccgen_firmware_folder%\BOOT0.bin" del /q "update_packages\%emmchaccgen_firmware_folder%\BOOT0.bin" >nul
					rename "update_packages\%emmchaccgen_firmware_folder%\BOOT0.bin.bak" "BOOT0.bin" >nul
					call "%associed_language_script%" "boot0_keyblobs_reparation_error"
					pause
					goto:pass_boot0_creation
				) else (
					del /q "update_packages\%emmchaccgen_firmware_folder%\BOOT0.bin.bak"
					call "%associed_language_script%" "boot0_keyblobs_reparation_success"
					pause
					goto:pass_boot0_creation
				)
			) else (
				del /q "update_packages\%emmchaccgen_firmware_folder%\BOOT0.bin.bak"
				call "%associed_language_script%" "boot0_keyblobs_reparation_success"
				pause
				goto:pass_boot0_creation
			)
		)
	)
)
:pass_boot0_creation
call "%associed_language_script%" "copy_begin_info"
IF EXIST "%volume_letter%:\cdj_package_files" rmdir /s /q "%volume_letter%:\cdj_package_files"
mkdir "%volume_letter%:\cdj_package_files"
IF !errorlevel! NEQ 0 (
	call "%associed_language_script%" "copy_to_sd_error"
	goto:endscript
)
mkdir "%volume_letter%:\cdj_package_files\SYSTEM"
IF !errorlevel! NEQ 0 (
	call "%associed_language_script%" "copy_to_sd_error"
	goto:endscript
)
IF EXIST "%volume_letter%:\bootloader\patches.ini" rename "%volume_letter%:\bootloader\patches.ini" "patches.ini.bak" >nul
%windir%\System32\Robocopy.exe tools\unbrick_special_SD_files %volume_letter%:\ /e >nul
IF EXIST "%volume_letter%:\bootloader\patches.ini.bak" (
	del /q "%volume_letter%:\bootloader\patches.ini" >nul
	rename "%volume_letter%:\bootloader\patches.ini.bak" "patches.ini" >nul
)
if "%method_creation_firmware_unbrick_choice%"=="1" (
	%windir%\System32\Robocopy.exe update_packages\NX-5.1.0_exfat\SYSTEM %volume_letter%:\cdj_package_files\SYSTEM /e >nul
	copy "update_packages\NX-5.1.0_exfat\*.bin" "%volume_letter%:\cdj_package_files" >nul
	IF !errorlevel! NEQ 0 (
		call "%associed_language_script%" "copy_to_sd_error"
		goto:endscript
	)
	copy "update_packages\NX-5.1.0_exfat\microSD\FS510-exfat_nocmac_nogc.kip1" "%volume_letter%:\cdj_package_files\FS510-exfat_nocmac_nogc.kip1" >nul
	IF !errorlevel! NEQ 0 (
		call "%associed_language_script%" "copy_to_sd_error"
		goto:endscript
	)
) else if "%method_creation_firmware_unbrick_choice%"=="2" (
	%windir%\System32\Robocopy.exe "update_packages\!emmchaccgen_firmware_folder!\SYSTEM " %volume_letter%:\cdj_package_files\SYSTEM /e >nul
	copy "update_packages\!emmchaccgen_firmware_folder!\*.bin" "%volume_letter%:\cdj_package_files" >nul
	IF !errorlevel! NEQ 0 (
		call "%associed_language_script%" "copy_to_sd_error"
		goto:endscript
	)
)
copy "%language_path%\tegra_scripts\cdj_restore_firmware_TE4.te" "%volume_letter%:\cdj_restore_firmware.te" >nul
IF !errorlevel! NEQ 0 (
	call "%associed_language_script%" "copy_to_sd_error"
	goto:endscript
)
IF EXIST "%volume_letter%:\atmosphere\contents\010000000000000D\*.*" rmdir /s /q "%volume_letter%:\atmosphere\contents\010000000000000D"
IF EXIST "%volume_letter%:\atmosphere\contents\010000000000002B\*.*" rmdir /s /q "%volume_letter%:\atmosphere\contents\010000000000002B"
IF EXIST "%volume_letter%:\atmosphere\contents\010000000000003C\*.*" rmdir /s /q "%volume_letter%:\atmosphere\contents\010000000000003C"
IF EXIST "%volume_letter%:\atmosphere\contents\0100000000000008\*.*" rmdir /s /q "%volume_letter%:\atmosphere\contents\0100000000000008"
IF EXIST "%volume_letter%:\atmosphere\contents\0100000000000032\*.*" rmdir /s /q "%volume_letter%:\atmosphere\contents\0100000000000032"
IF EXIST "%volume_letter%:\atmosphere\contents\0100000000000034\*.*" rmdir /s /q "%volume_letter%:\atmosphere\contents\0100000000000034"
IF EXIST "%volume_letter%:\atmosphere\contents\0100000000000036\*.*" rmdir /s /q "%volume_letter%:\atmosphere\contents\0100000000000036"
IF EXIST "%volume_letter%:\atmosphere\contents\0100000000000037\*.*" rmdir /s /q "%volume_letter%:\atmosphere\contents\0100000000000037"
IF EXIST "%volume_letter%:\atmosphere\contents\0100000000000042\*.*" rmdir /s /q "%volume_letter%:\atmosphere\contents\0100000000000042"
IF EXIST "%volume_letter%:\sept\payload.bin" del /q "%volume_letter%:\sept\payload.bin" >nul
IF EXIST "%volume_letter%:\atmosphere\fusee-mtc.bin" del /q "%volume_letter%:\atmosphere\fusee-mtc.bin" >nul
IF EXIST "%volume_letter%:\atmosphere\kip_patches\default_nogc\*.*" rmdir /s /q "%volume_letter%:\atmosphere\kip_patches\default_nogc" >nul
IF EXIST "%volume_letter%:\atmosphere\config\BCT.ini" del /q "%volume_letter%:\atmosphere\config\BCT.ini" >nul
IF EXIST "%volume_letter%:\atmosphere\config_templates\BCT.ini" del /q "%volume_letter%:\atmosphere\config_templates\BCT.ini" >nul
IF EXIST "%volume_letter%:\atmosphere\fusee-secondary.bin" del /q "%volume_letter%:\atmosphere\fusee-secondary.bin" >nul
IF EXIST "%volume_letter%:\atmosphere\flags\clean_stratosphere_for_0.19.0.flag" del /q "%volume_letter%:\atmosphere\flags\clean_stratosphere_for_0.19.0.flag" >nul
del /Q /S "%volume_letter%:\Atmosphere_fusee-primary.bin" >nul 2>&1
del /Q /S "%volume_letter%:\atmosphere\.emptydir" >nul
del /Q /S "%volume_letter%:\bootloader\.emptydir" >nul
del /q "%volume_letter%:\folder_version.txt" >nul
IF /i "%mariko_console%"=="O" (
	rmdir /s /q "%volume_letter%:\payloads" >nul
	rmdir /s /q "%volume_letter%:\switch\ChoiDuJourNX" >nul
	rmdir /s /q "%volume_letter%:\switch\Payload_Launcher" >nul
)
echo.
set restore_method=
IF /i "%patched_console%"=="O" (
	set restore_method=1
	goto:end_copy_to_sd
)
call "%associed_language_script%" "restore_method_choice"
IF %errorlevel% equ 1 (
	set restore_method=1
	goto:end_copy_to_sd
)
IF %errorlevel% equ 2 (
	set restore_method=2
	goto:end_copy_to_sd
)
goto:endscript2
:end_copy_to_sd
call "%associed_language_script%" "copying_end"

:launch_tegraexplorer
echo.
call "%associed_language_script%" "tegraexplorer_launch_begin"
IF /i NOT "%patched_console%"=="O" tools\TegraRcmSmash\TegraRcmSmash.exe -w "tools\payloads\TegraExplorer.bin"
call "%associed_language_script%" "tegraexplorer_launch_correctly_question"
IF %errorlevel% EQU 2 goto:launch_tegraexplorer
call "%associed_language_script%" "tegraexplorer_launch_end"
pause
IF NOT "%restore_method%"=="2" goto:launch_hekate
:hacdiskmount_step
echo.
call "%associed_language_script%" "memloader_launch_begin"
IF /i NOT "%patched_console%"=="O" tools\TegraRcmSmash\TegraRcmSmash.exe -w tools\memloader\memloader_usb.bin --dataini="tools\memloader\mount_discs\ums_emmc.ini"
call "%associed_language_script%" "memloader_launch_correctly_question"
IF %errorlevel% EQU 2 goto:hacdiskmount_step
call "%associed_language_script%" "memloader_launch_end"
pause
start tools\HacDiskMount\HacDiskMount.exe
if "%method_creation_firmware_unbrick_choice%"=="1" (
	start explorer.exe "update_packages\NX-5.1.0_exfat"
) else if "%method_creation_firmware_unbrick_choice%"=="2" (
	start explorer.exe "update_packages\%emmchaccgen_firmware_folder%"
)
:launch_hekate
echo.
call "%associed_language_script%" "hekate_launch_begin"
IF %errorlevel% EQU 2 goto:launch_hekate_end
:hekate_after_first_launch
call "%associed_language_script%" "hekate_rcm_instruction"
IF /i NOT "%patched_console%"=="O" tools\TegraRcmSmash\TegraRcmSmash.exe -w "tools\payloads\hekate.bin"
:launch_hekate_end
call "%associed_language_script%" "hekate_launch_end"
IF %errorlevel% EQU 1 goto:hekate_after_first_launch
call "%associed_language_script%" "script_end_message"
goto:endscript

:daybreak_convert
IF NOT EXIST "tools\Hactool_based_programs\keys.txt" (
	call "%associed_language_script%" "daybreak_keys_file_select_passed"
	pause
	exit /b
)
call "%associed_language_script%" "daybreak_convert_begin"
rem set /a count_loop = 0
for /d %%f in ("%~1\*.nca") do (
	move "%%f" "%%f.bak" >nul
	move "%%f.bak\00" "%%f" >nul
	rmdir "%%f.bak"
)
for %%f in ("%~1\*.nca") do (
	IF NOT EXIST "%%f\*.*" (
		set temp_file_name=%%f
		IF NOT "!temp_file_name:~-9,9!"==".cnmt.nca" (
			rem set /a count_loop = !count_loop!+1
			rem tools\Hactool_based_programs\tools\hactool.exe -k "%keys_file_path%" -i "!temp_file_name!" >templogs\temptest.txt 2>&1
			tools\Hactool_based_programs\hactoolnet.exe -k "tools\Hactool_based_programs\keys.txt" "!temp_file_name!" >templogs\temptest.txt 2>&1
			tools\gnuwin32\bin\grep.exe -c -i "ERROR: Unable to decrypt NCA section." <"templogs\temptest.txt" >templogs\tempvar.txt
			set /p temp_count=<templogs\tempvar.txt
			IF NOT "!temp_count!"=="0" (
				call "%associed_language_script%" "daybreak_convert_keys_warning"
				pause
				exit /b
			)
			rem pause
			rem notepad "templogs\temptest.txt"
			tools\gnuwin32\bin\grep.exe -c -i -e "Content Type: *Meta" <"templogs\temptest.txt" >templogs\tempvar.txt
			set /p temp_count=<templogs\tempvar.txt
			IF NOT "!temp_count!"=="0" (
			rem echo Meta trouvé.
			move "!temp_file_name!" "!temp_file_name:~0,-3!cnmt.nca" >nul
			)
		) else IF "!temp_file_name:~-9,9!"==".cnmt.nca" (
			rem set /a count_loop = !count_loop!+1
			rem tools\Hactool_based_programs\tools\hactool.exe -k "tools\Hactool_based_programs\keys.txt" -i "!temp_file_name!" >templogs\temptest.txt 2>&1
			tools\Hactool_based_programs\hactoolnet.exe -k "tools\Hactool_based_programs\keys.txt" "!temp_file_name!" >templogs\temptest.txt 2>&1
			tools\gnuwin32\bin\grep.exe -c -i "ERROR: Unable to decrypt NCA section." <"templogs\temptest.txt" >templogs\tempvar.txt
			set /p temp_count=<templogs\tempvar.txt
			IF NOT "!temp_count!"=="0" (
				call "%associed_language_script%" "daybreak_convert_keys_warning"
				pause
				exit /b
			)
			rem pause
			rem notepad "templogs\temptest.txt"
			tools\gnuwin32\bin\grep.exe -c -i -e "Content Type: *Meta" <"templogs\temptest.txt" >templogs\tempvar.txt
			set /p temp_count=<templogs\tempvar.txt
			IF "!temp_count!"=="0" (
			rem echo NCA mal nommé.
			move "!temp_file_name!" "!temp_file_name:~0,-8!nca" >nul
			)
		)
	)
)
rem echo %count_loop%
exit /b

:endscript
pause
:endscript2
IF EXIST "firmware_temp" rmdir /s /q "firmware_temp"
IF EXIST "update_packages" rmdir /s /q "update_packages"
rmdir /s /q templogs
endlocal