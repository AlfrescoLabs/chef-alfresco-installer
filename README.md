chef-alfresco-installer Cookbook
======================
This is a cookbook for installing alfresco using multiple deployement schemas and platforms

This is an experimental cookbook and partially implemented!!!


Requirements
------------
java
apt
chef-client


Usage
-----
#### alfresco-chef::installer

e.g.
Just include `alfresco-chef` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[alfresco_chef::installer]"
  ]
}
```

Contributing
------------

1. Fork the repository on Github
2. Create a feature branch corresponding to you change
3. Commit and test thoroughly
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Sergiu Vidrascu (vsergiu@hotmail.com)
