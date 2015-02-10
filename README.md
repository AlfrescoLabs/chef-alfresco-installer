alfresco_java Cookbook
======================
This is a wrapper cookbook for java modified to fit the alfresco internal process.
It currently installs java from a local repository.

This is an experimental cookbook!!!


Requirements
------------
java cookbook 1.7.0 or higher


Usage
-----
#### alfresco_java::java8

e.g.
Just include `alfresco_java` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[alfresco_java::java8]"
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
