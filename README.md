Ansible Role: oracle-manage-patches
===================================

This role manages Oracle patches.

It applies and rolls back the patches (one-off and quarterly patches) to Grid Infrastructure and/or Database Oracle Homes (both PRIMARY and STANDBY).

Additionally, it is possible to restrict affected ORACLE_HOMEs by providing either ORACLE_HOME paths directly (`oracle_manage_patches_oracle_home_name_patterns`) or software versions (`oracle_manage_patches_oracle_home_version_patterns`) to be considered. Otherwise, all ORACLE_HOMEs of any version related to provided patch name will be affected. Other ORACLE_HOMEs and databases, not related to selected patch name, will not be touched.

The role is RAC-aware and applies patches to all cluster nodes whenever Real Application Cluster is detected, even if the playbook is executed only on one of RAC nodes (ansible-playbook `--limit` argument).

For standby databases only binaries are patched, none of sql/datapatch scrips are executed.

As an option the following features are available:
* ORACLE_HOMEs backup (prior patch installation) - (`oracle_manage_patches_backup_oracle_home` switch + `oracle-homes-backup` role)
* ASM metadata backup (prior patch installation) - (`oracle_manage_patches_backup_asm_metadata` switch and `oracle_manage_patches_backup_dir` variable)
* pre- and post- check scripts (opatch lsinventory output, list of INVALID objects, output of `registry$history`, `dba_registry_sqlpatch`, `dba_registry_history` and `dba_registry` tables) which log their activity to `oracle_manage_patches_log_dir` directory on targets
* download patch directly from My Oracle Support (`oracle_manage_patches_download_patch_from_mos` switch + `oracle-download-patches` role)


This role expects the following variables to be set (either in the playbook or via `--extra-vars` - see examples below):
* `oracle_manage_patches_task` - either `apply` or `rollback`
* `oracle_manage_patches_patch_type` - either 'oneoff' or any 'oracle_manage_patches_quarterly_patches' key (i.e. ojvmgicombo/ojvmdbcombo/ru/dbbp/psu)
* `oracle_manage_patches_patch_name` - patch name (e.g. OCT2018/JUL2018) for quarterly patches


List of databases should be provided with `oracle_databases` variable (See `oracle` role for reference). It might be defined manually or populated dynamically with auto discovery role `oracle-gatherinfo-databases` (see example in *Example Playbook* section). When set up manually, `oracle_databases` ought to be defined as follows:

    oracle_databases:
      - cluster_database: "false"
        database_role: "PRIMARY"
        database_type: "SINGLE"
        db_name: "ORCL"
        db_unique_name: "ORCL"
        edition: "Enterprise"
        instance_name: "ORCL"
        instances: "ORCL"
        is_registered_in_gi: "true"
        oracle_home: "/u01/app/oracle/product/11.2.0.4/dbhome1"
        software_version: "11.2.0.4.0"
	  - (...)

	  
Similarly, Grid Infrastructure configuration should be provided with `oracle_gi_info` dict variable (See `oracle` role for reference). It might be defined manually or populated dynamically with auto discovery role `oracle-gatherinfo-gi` (see example in *Example Playbook* section). When set up manually, `oracle_gi_info` ought to be defined as follows (example):

    oracle_gi_info:
      oracle_home: "/u01/app/12.1.0/grid"
      rac_nodes: []
      rac_remote_nodes: []
      software_version: "12.1.0.2.0"

or 
	  
    oracle_gi_info:
      oracle_home: "/u01/app/12.1.0/grid"
      rac_nodes: [ 'server1', 'server2' ]
      rac_remote_nodes: [ 'server2' ]
      software_version: "12.1.0.2.0"
  

It is strongly recommended to trigger auto discovery roles `oracle-gatherinfo-listener` and `oracle-gatherinfo-dbconsole` before running this role (see example in *Example Playbook* section). These roles populate `oracle_running_listeners` and `oracle_dbconsole_running_services` variables which are used by this (`oracle-manage-patches`) role to bring the systems back to exactly the same state as before.
  
  
Lists of patches are defined with `oracle_manage_patches_opatch`, `oracle_manage_patches_quarterly_patches` and `oracle_manage_patches_oneoff_patches` variables. See *Role Variables* for details.

Patch zip files may be accessible either on the remote systems or, locally, on the Ansible controller. To point out which configuration is applicable use `oracle_manage_patches_remote_stage` variable.

The role automatically installs the latest OPatch utility for affected ORACLE_HOMEs according to `oracle_manage_patches_opatch` data.

  
Supported OS:
-------------
* RedHat
* CentOS
* OracleLinux

Requirements
------------

This role uses `oracle`, `oracle-asm-metadata`, `oracle-homes-backup` and `oracle-download-patches` roles.


This role expects the following variables to be set (either in the playbook or via `--extra-vars` - see examples below):
* `oracle_manage_patches_task` - either `apply` or `rollback`
* `oracle_manage_patches_patch_type` - either 'oneoff' or any 'oracle_manage_patches_quarterly_patches' key (i.e. ojvmgicombo/ojvmdbcombo/ru/dbbp/psu)
* `oracle_manage_patches_patch_name` - patch name (e.g. OCT2018/JUL2018) for quarterly patches


Role Variables
--------------

Available variables are listed below, along with default values (see `defaults/main.yml`):


    #
    # Input parameters
    #

    # Either 'oneoff' or any 'oracle_manage_patches_quarterly_patches' key (i.e. ojvmgicombo/ojvmdbcombo/ru/dbbp/psu)
    oracle_manage_patches_patch_type:

    # Patch name (e.g. OCT2018/JUL2018) for quarterly patches
    oracle_manage_patches_patch_name:

    # Patch task - either apply or rollback
    oracle_manage_patches_task: apply

    #
    # Conditionals and control handling
    #

    # Backup ORACLE_HOME before patch apply
    oracle_manage_patches_backup_oracle_home: false

    # Backup ASM metadata before patch apply
    oracle_manage_patches_backup_asm_metadata: false

    # Download patches from My Oracle Support
    oracle_manage_patches_download_patch_from_mos: false

    # Patch ORACLE_HOMEs/GRID_HOMEs with names matching any string from this list (OR)
    oracle_manage_patches_oracle_home_name_patterns: []

    # Example:
    #oracle_manage_patches_oracle_home_name_patterns:
    #  - '/u01/app/oracle/product/11.2.0/dbhome_1'
    #  - '/u01/app/oracle/product/12.1.0/dbhome_2'
    #  - '/u01/app/12.1.0/grid'

    # Patch ORACLE_HOMEs/GRID_HOMEs with version matching any string from this list (OR)
    oracle_manage_patches_oracle_home_version_patterns: []

    # Example:
    #oracle_manage_patches_oracle_home_version_patterns:
    #  - 11.2.0.4.0
    #  - 12.1.0.2.0

    # Display 'opatch lsinventory' output
    oracle_manage_patches_display_opatch_lsinventory_output: true

    # Display 'opatchauto -analyze' output
    oracle_manage_patches_display_opatchauto_analyze_output: true

    # Display 'ojvm conflict detection' output
    oracle_manage_patches_display_ojvm_conflict_detection_output: true

    # Display 'opatchauto apply' output
    oracle_manage_patches_display_opatchauto_apply_output: true

    # Display 'datapatch' output
    oracle_manage_patches_display_datapatch_output: true

    # whether or not run pre scripts (opatch lsinventory/db_psu_apply_checks.sql/etc)
    oracle_manage_patches_run_pre_scripts: true

    # whether or not run post scripts (opatch lsinventory/db_psu_apply_checks.sql/etc)
    oracle_manage_patches_run_post_scripts: true

    # execute patch conflict detection
    oracle_manage_patches_conflict_detection: true

    # execute patch installation (set 'false' only for debugging)
    oracle_manage_patches_patch_installation: true

    #
    # Stage location, installation files
    #

    # Set to 'true' to indicate that the stage directory with patch zip files is accessible on the remote system
    #   and not local to the Ansible controller
    # Set to 'false' to copy patch files from the Ansible controller to the remote system
    oracle_manage_patches_remote_stage: true

    # Stage directory for OPatch utility
    oracle_manage_patches_stage_dir_opatch: /software/rdbms/opatch

    # whether or not update (extract) OPatch utility
    oracle_manage_patches_update_opatch: true

    # whether or not extract patch zip file
    oracle_manage_patches_extract_patch_file: true

    # Stage directory for Oracle quarterly patches archives (PSU/RU/etc.)
    oracle_manage_patches_stage_dir_quarterly_patches: /software/rdbms/quarterly_patches

    # A list of opatch files
    #   'filename' should either be a full path or it will be searched in 'oracle_manage_patches_stage_dir_opatch' directory

    oracle_manage_patches_opatch:
      11.2.0.1:
        filename: p6880880_112000_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
      11.2.0.2:
        filename: p6880880_112000_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
      11.2.0.3:
        filename: p6880880_112000_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
      11.2.0.4:
        filename: p6880880_112000_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
      12.1.0.1:
        filename: p6880880_121010_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
      12.1.0.2:
        filename: p6880880_122010_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
      12.2.0.1:
        filename: p6880880_122010_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
      18.0.0.0:
        filename: p6880880_180000_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip


    # A list of quarterly patches
    #   'filename' should either be a full path or it will be searched in 'oracle_manage_patches_stage_dir_quarterly_patches' directory

    oracle_manage_patches_quarterly_patches:
	
      ojvmgicombo:
        description: 'Combo of OJVM component DB PSU + GI PSU'
        12.1.0.2:
          JAN2019:
            patchversion: 12.1.0.2.190115
            filename: p28980120_121020_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
            patchid: 28980120
            gi_patchid: 28813884
            ojvm_patchid: 28790654
          OCT2018:
            patchversion: 12.1.0.2.181016
            filename: p28689148_121020_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
            patchid: 28689148
            gi_patchid: 28349311
            ojvm_patchid: 28440711
          JUL2018:
            patchversion: 12.1.0.2.180717
            filename: p28317214_121020_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
            patchid: 28317214
            gi_patchid: 27967747
            ojvm_patchid: 27923320
        12.2.0.1:
          JAN2018:
            patchversion: 12.2.0.1.180116
            filename: p27010711_122010_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
            patchid: 27010711
            gi_patchid: 27100009
            ojvm_patchid: 27001739
			
      ojvmdbcombo:
        description: 'Combo of OJVM component DB PSU + DB PSU'
        11.2.0.4:
          OCT2018:
            patchversion: 11.2.0.4.181016
            filename: p28689165_112040_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
            patchid: 28689165
            db_patchid: 28204707
            ojvm_patchid: 28440700
          JUL2018:
            patchversion: 11.2.0.4.180717
            filename: p28317183_112040_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
            patchid: 28317183
            db_patchid: 27734982
            ojvm_patchid: 27923163
			
      ru:
        description: 'Release Update Patch (RU)'
        12.2.0.1:
          JUL2018:
            patchversion: 12.2.0.1.180717
            filename: p28183653_122010_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
            patchid: 28183653
            si_patchid: 28163133
      dbbp:
        description: 'Database Proactive Bundle Patch (BP)'
        12.1.0.2:
          JUL2017:
            patchversion: 12.1.0.2.170718
            filename: p26022196_121020_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
            patchid: 26022196
            si_patchid: 25869760
      psu:
        description: 'Patch Set Update (PSU)'
        11.2.0.4:
          JUL2017:
            patchversion: 11.2.0.4.170718
            filename: p26030799_112040_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
            patchid: 26030799
            si_patchid: 25869727

    oracle_manage_patches_oneoff_patches: []

    #
    # Log/backup/install directories
    #

    # Backup directory used for different non-database backups, such as ASM metadata, OCR registry backup, etc
    oracle_manage_patches_backup_dir: '{{ oracle_default_backup_dir|default( "/u01/app/psu/backup", true ) }}'

    # Log directory
    oracle_manage_patches_log_dir: '{{ oracle_default_log_dir|default( "/u01/app/psu/log", true ) }}'

    # Stage install directory
    oracle_manage_patches_stage_install_dir: '{{ oracle_default_stage_install_dir|default( "/u01/app/oracle/install", true ) }}'

    #
    # Debug info
    #

    # (debug) display patches information
    oracle_manage_patches_debug_display_patches_info: true

    # (debug) display ORACLE_HOMEs selected for patching
    oracle_manage_patches_debug_display_homes_selected_for_patching: true

			
Dependencies
------------

This role uses `oracle`, `oracle-asm-metadata`, `oracle-homes-backup` and `oracle-download-patches` roles.

Example Playbook
----------------

A simple example:

    - name: Apply Oracle Patches
      hosts: ora-servers
      gather_facts: true
      become: true
      become_user: '{{ oracle_user }}'

      tasks:
	  
      - import_role:
          name: oracle-manage-patches
        vars:
          oracle_manage_patches_task: apply
          oracle_manage_patches_patch_type: ojvmgicombo   
          oracle_manage_patches_patch_name: OCT2018
        tags:
          - oracle-manage-patches
		  
		  
A complex example (with additional features, such as GI/DB auto discovery, cronjobs and monitoring support [disable/enable]):

    - name: Apply Oracle Patches
      hosts: ora-servers
      gather_facts: true
      become: true
      become_user: '{{ oracle_user }}'

      vars:
        oracle_apply_patches_manage_monitoring: true
        oracle_apply_patches_manage_cron_jobs: true
        oracle_apply_patches_downtime_duration: '3h'
        oracle_apply_patches_single_host_mode: true

      tasks:

      - name: Check a single host mode
        assert:
          that:
            - "play_hosts|length == 1"
          fail_msg: "This is a 'single host' mode, but more than one host seems to be in the current play"
        run_once: true
        when: oracle_apply_patches_single_host_mode
        tags:
          - oracle_apply_patches_precheck
          - always

      - import_role:
          name: oracle-gatherinfo-gi
        tags:
          - oracle-gatherinfo-gi
          - oracle-gatherinfo-allcomponents

      - import_role:
          name: oracle-gatherinfo-databases
        tags:
          - oracle-gatherinfo-databases
          - oracle-gatherinfo-allcomponents

      - import_role:
          name: oracle-gatherinfo-listener
        tags:
          - oracle-gatherinfo-listener
          - oracle-gatherinfo-allcomponents

      - import_role:
          name: oracle-gatherinfo-dbconsole
        tags:
          - oracle-gatherinfo-dbconsole
          - oracle-gatherinfo-allcomponents

      - include_role:
          name: oracle-host-cron
        vars:
          oracle_host_cron_copy_scripts: false
          oracle_host_cron_disable_jobs: true
          oracle_host_cron_manage_cron_jobs: '{{ oracle_apply_patches_manage_cron_jobs }}'
        when: oracle_apply_patches_manage_cron_jobs
        tags:
          - oracle_disable_cron_jobs

      - include_tasks: monitoring_set_downtime.yml
        with_items:
          - '{{ inventory_hostname }}'
          - '{{ oracle_gi_info.rac_remote_nodes }}'
        loop_control:
          label: "[host: {{ _oracle_apply_patches_host_outer_item }}]"
          loop_var: _oracle_apply_patches_host_outer_item
        when: oracle_apply_patches_manage_monitoring
        tags:
          - nacl_manage_checks_set_downtime

      - import_role:
          name: oracle-manage-patches
        vars:
          oracle_manage_patches_task: apply
          oracle_manage_patches_patch_type: ojvmgicombo   
          oracle_manage_patches_patch_name: OCT2018
        tags:
          - oracle-manage-patches

      - include_tasks: monitoring_cancel_downtime.yml
        with_items:
          - '{{ inventory_hostname }}'
          - '{{ oracle_gi_info.rac_remote_nodes }}'
        loop_control:
          label: "[host: {{ _oracle_apply_patches_host_outer_item }}]"
          loop_var: _oracle_apply_patches_host_outer_item
        when: oracle_apply_patches_manage_monitoring
        tags:
          - nacl_manage_checks_cancel_downtime

      - include_role:
          name: oracle-host-cron
        vars:
          oracle_host_cron_copy_scripts: false
          oracle_host_cron_disable_jobs: false
          oracle_host_cron_manage_cron_jobs: '{{ oracle_apply_patches_manage_cron_jobs }}'
        when: oracle_apply_patches_manage_cron_jobs
        tags:
          - oracle_enable_cron_jobs

          

Inside `vars/main.yml` or `group_vars/..` or `host_vars/..`:


    #-------------------------------------------------
    # overrides role 'oracle-manage-patches' variables
    #-------------------------------------------------

    # Set to 'true' to indicate that the stage directory with patch zip files is accessible on the remote system
    #   and not local to the Ansible controller
    # Set to 'false' to copy patch files from the Ansible controller to the remote system
    oracle_manage_patches_remote_stage: true

    # Stage directory for OPatch utility
    oracle_manage_patches_stage_dir_opatch: /software/rdbms/opatch

    # Stage directory for Oracle quarterly patches archives (PSU/RU/etc.)
    oracle_manage_patches_stage_dir_quarterly_patches: /software/rdbms/quarterly_patches

    # A list of opatch files
    #   'filename' should either be a full path or it will be searched in 'oracle_manage_patches_stage_dir_opatch' directory
    oracle_manage_patches_opatch:
      11.2.0.4:
        filename: p6880880_112000_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
      12.1.0.2:
        filename: p6880880_122010_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
      12.2.0.1:
        filename: p6880880_122010_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
      18.0.0.0:
        filename: p6880880_180000_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip

    # A list of quarterly patches
    #   'filename' should either be a full path or it will be searched in 'oracle_manage_patches_stage_dir_quarterly_patches' directory

    oracle_manage_patches_quarterly_patches:
      ojvmgicombo:
        description: 'Combo of OJVM component DB PSU + GI PSU'
        12.1.0.2:
          OCT2018:
            patchversion: 12.1.0.2.181016
            filename: p28689148_121020_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
            patchid: 28689148
            gi_patchid: 28349311
            ojvm_patchid: 28440711
      ojvmdbcombo:
        description: 'Combo of OJVM component DB PSU + DB PSU'
        11.2.0.4:
          OCT2018:
            patchversion: 11.2.0.4.181016
            filename: p28689165_112040_{{ ansible_system }}-{{ ansible_architecture | replace('_', '-') }}.zip
            patchid: 28689165
            db_patchid: 28204707
            ojvm_patchid: 28440700


    # ... etc ...


License
-------

GPLv3 - GNU General Public License v3.0

Author Information
------------------

This role was created in 2018 by [Krzysztof Lewandowski](mailto:Krzysztof.Lewandowski@fastmail.fm).


