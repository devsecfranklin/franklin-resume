# Workloads and Scheduling

- Taints
  - Discourage pod assignments

```sh
k taint node head1.lab.bitsmasher.net dedicated:NoSchedule
```

- Tolerations
  - line in metadata to encourage pod assignment
