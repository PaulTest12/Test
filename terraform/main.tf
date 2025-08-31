[targets]
127.0.0.1 ansible_port=${ssh_port} ansible_user=root ansible_password=root ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python3


---
- name: Konfiguracja serwera WWW
  hosts: targets
  become: true
  gather_facts: true

  vars:
    html_file: /var/www/html/index.html

  tasks:
    - name: Aktualizacja cache apt
      apt:
        update_cache: yes
      when: ansible_os_family == "Debian"

    - name: Instalacja nginx
      apt:
        name: nginx
        state: present
      notify: Restart nginx

    - name: Utworzenie strony index.html
      copy:
        dest: "{{ html_file }}"
        content: |
          <html>
          <body>
          <h1>Serwer z Ansible 🚀</h1>
          <p>Data: {{ ansible_date_time.date }} {{ ansible_date_time.time }}</p>
          </body>
          </html>
      notify: Restart nginx

  handlers:
    - name: Restart nginx
      shell: |
        if pgrep nginx; then
          nginx -s reload
        else
          nginx
        fi
      args:
        warn: false
