// ── Course content data ───────────────────────────────────────────────────────
// All 4 courses with modules, lessons (text + video + key points)

class LessonContent {
  const LessonContent({
    required this.id,
    required this.title,
    required this.duration,
    required this.youtubeUrl,
    required this.summary,
    required this.keyPoints,
  });
  final String id;
  final String title;
  final String duration;
  final String youtubeUrl;
  final String summary;
  final List<String> keyPoints;
}

class CourseModule {
  const CourseModule({required this.title, required this.lessons});
  final String title;
  final List<LessonContent> lessons;
}

class CourseInfo {
  const CourseInfo({
    required this.id,
    required this.title,
    required this.category,
    required this.estimatedHours,
    required this.modules,
  });
  final String id;
  final String title;
  final String category;
  final int estimatedHours;
  final List<CourseModule> modules;

  int get totalLessons =>
      modules.fold(0, (s, m) => s + m.lessons.length);
}

// ─────────────────────────────────────────────────────────────────────────────

final List<CourseInfo> allCourses = [
  // ── 1. Cloud Computing Basics ─────────────────────────────────────────────
  CourseInfo(
    id: 'cloud-computing-basics',
    title: 'Cloud Computing Basics',
    category: 'Cloud',
    estimatedHours: 8,
    modules: [
      CourseModule(title: 'Module 1: Introduction to Cloud', lessons: [
        LessonContent(
          id: 'cc1_1',
          title: 'What is Cloud Computing?',
          duration: '8 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=M988_fsOSWo',
          summary:
              'Cloud computing is the delivery of computing services—servers, storage, databases, networking, software, analytics, and intelligence—over the internet ("the cloud") to offer faster innovation, flexible resources, and economies of scale.',
          keyPoints: [
            'Cloud = on-demand IT resources over the internet',
            'Pay only for what you use (pay-as-you-go)',
            'Eliminates need for physical hardware management',
            'Enables global access from any device',
            'Major providers: AWS, Azure, Google Cloud',
          ],
        ),
        LessonContent(
          id: 'cc1_2',
          title: 'Cloud Service Models: IaaS, PaaS, SaaS',
          duration: '10 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=9CVBohl6w0Q',
          summary:
              'Cloud services are broadly divided into three categories. IaaS provides raw infrastructure, PaaS provides a platform for developers to build apps, and SaaS delivers ready-to-use software over the internet.',
          keyPoints: [
            'IaaS: Virtual machines, storage, networking (e.g. AWS EC2)',
            'PaaS: Development platforms, databases (e.g. Google App Engine)',
            'SaaS: Ready-made apps (e.g. Gmail, Salesforce)',
            'Each model shifts more responsibility to the provider',
            'Choose based on control vs convenience trade-off',
          ],
        ),
        LessonContent(
          id: 'cc1_3',
          title: 'Public, Private & Hybrid Cloud',
          duration: '7 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=3meFAfJBMf8',
          summary:
              'Organizations can deploy cloud in three ways: public (shared infrastructure), private (dedicated infrastructure), or hybrid (combination of both). Each has distinct security, cost, and flexibility trade-offs.',
          keyPoints: [
            'Public cloud: Shared, cost-effective, managed by provider',
            'Private cloud: Dedicated, more control, higher cost',
            'Hybrid cloud: Best of both worlds',
            'Multi-cloud: Using multiple providers simultaneously',
            'Choice depends on compliance and security needs',
          ],
        ),
      ]),
      CourseModule(title: 'Module 2: Cloud Architecture', lessons: [
        LessonContent(
          id: 'cc2_1',
          title: 'Virtualization Explained',
          duration: '9 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=FZR0rG3HKIk',
          summary:
              'Virtualization is the foundation of cloud computing. It allows multiple virtual machines to run on a single physical server, maximizing hardware utilization and enabling rapid provisioning.',
          keyPoints: [
            'Hypervisor creates and manages virtual machines',
            'Type 1 (bare-metal) vs Type 2 (hosted) hypervisors',
            'VMs share physical CPU, RAM, and storage',
            'Enables isolation between workloads',
            'Containers are a lighter alternative to VMs',
          ],
        ),
        LessonContent(
          id: 'cc2_2',
          title: 'Scalability & Load Balancing',
          duration: '11 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=K0Ta65OqQkY',
          summary:
              'Scalability allows systems to handle growing workloads. Horizontal scaling adds more servers; vertical scaling adds more power to existing servers. Load balancers distribute traffic evenly across servers.',
          keyPoints: [
            'Horizontal scaling: Add more servers (scale out)',
            'Vertical scaling: Upgrade existing server (scale up)',
            'Auto-scaling adjusts capacity automatically',
            'Load balancer distributes requests evenly',
            'Elastic scaling saves cost during low traffic',
          ],
        ),
      ]),
      CourseModule(title: 'Module 3: Cloud Security', lessons: [
        LessonContent(
          id: 'cc3_1',
          title: 'Cloud Security Fundamentals',
          duration: '12 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=0ldy8oTjMlI',
          summary:
              'Cloud security involves policies, technologies, and controls to protect data, applications, and infrastructure. The shared responsibility model defines what the provider secures vs what the customer must secure.',
          keyPoints: [
            'Shared responsibility model: provider vs customer duties',
            'Data encryption at rest and in transit',
            'Network security groups and firewalls',
            'Regular security audits and compliance checks',
            'Zero-trust security model',
          ],
        ),
        LessonContent(
          id: 'cc3_2',
          title: 'Identity & Access Management',
          duration: '9 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=y8cbKJAo3B4',
          summary:
              'IAM controls who can access what resources in the cloud. It uses users, groups, roles, and policies to enforce least-privilege access, ensuring only authorized entities can perform specific actions.',
          keyPoints: [
            'Principle of least privilege',
            'Users, groups, roles, and policies',
            'Multi-factor authentication (MFA)',
            'Role-based access control (RBAC)',
            'Service accounts for applications',
          ],
        ),
      ]),
      CourseModule(title: 'Module 4: Deployment & DevOps', lessons: [
        LessonContent(
          id: 'cc4_1',
          title: 'CI/CD in the Cloud',
          duration: '14 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=scEDHsr3APg',
          summary:
              'CI/CD (Continuous Integration/Continuous Deployment) automates the process of building, testing, and deploying applications. Cloud platforms provide managed CI/CD services that integrate with code repositories.',
          keyPoints: [
            'CI: Automatically build and test on every code push',
            'CD: Automatically deploy tested code to production',
            'Pipeline stages: build → test → deploy',
            'Tools: GitHub Actions, AWS CodePipeline, Azure DevOps',
            'Reduces manual errors and speeds up releases',
          ],
        ),
        LessonContent(
          id: 'cc4_2',
          title: 'Containers vs Virtual Machines',
          duration: '8 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=cjXI-yenr-0',
          summary:
              'Containers package application code with its dependencies into a lightweight unit. Unlike VMs, containers share the host OS kernel, making them faster to start and more resource-efficient.',
          keyPoints: [
            'Containers share OS kernel, VMs have their own OS',
            'Docker is the most popular container runtime',
            'Containers start in milliseconds vs minutes for VMs',
            'Container images are portable across environments',
            'Kubernetes orchestrates containers at scale',
          ],
        ),
      ]),
    ],
  ),

  // ── 2. AWS Fundamentals ───────────────────────────────────────────────────
  CourseInfo(
    id: 'aws-fundamentals',
    title: 'AWS Fundamentals',
    category: 'AWS',
    estimatedHours: 10,
    modules: [
      CourseModule(title: 'Module 1: AWS Overview', lessons: [
        LessonContent(
          id: 'aws1_1',
          title: 'AWS Global Infrastructure',
          duration: '10 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=a9__D53WsUs',
          summary:
              'AWS operates in Regions and Availability Zones worldwide. Regions are geographic areas with multiple isolated data centers (AZs). This global infrastructure enables low latency, high availability, and disaster recovery.',
          keyPoints: [
            'AWS has 30+ Regions globally',
            'Each Region has 2–6 Availability Zones (AZs)',
            'AZs are physically separate data centers',
            'Edge Locations serve cached content via CloudFront',
            'Choose Region based on latency, compliance, cost',
          ],
        ),
        LessonContent(
          id: 'aws1_2',
          title: 'AWS Management Console Tour',
          duration: '8 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=IT1X42D1KeA',
          summary:
              'The AWS Management Console is a web-based interface for accessing and managing AWS services. It provides dashboards, service search, billing information, and account settings in one place.',
          keyPoints: [
            'Access all 200+ AWS services from one console',
            'Search bar for quick service navigation',
            'Resource groups to organize related resources',
            'Cost Explorer for billing visibility',
            'CloudShell for browser-based CLI access',
          ],
        ),
      ]),
      CourseModule(title: 'Module 2: Core AWS Services', lessons: [
        LessonContent(
          id: 'aws2_1',
          title: 'Amazon EC2 Explained',
          duration: '13 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=TsRBftzZsQo',
          summary:
              'Amazon EC2 (Elastic Compute Cloud) provides resizable virtual servers in the cloud. You can launch instances with different CPU, memory, and storage configurations to match your workload needs.',
          keyPoints: [
            'EC2 instances are virtual servers',
            'Instance types: General, Compute, Memory, Storage optimized',
            'AMI (Amazon Machine Image) is the instance template',
            'Security Groups act as virtual firewalls',
            'Elastic IP for static public IP addresses',
          ],
        ),
        LessonContent(
          id: 'aws2_2',
          title: 'Amazon S3 Deep Dive',
          duration: '11 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=77lMCiiMilo',
          summary:
              'Amazon S3 (Simple Storage Service) is object storage built for any amount of data. It stores files as objects in buckets, offering 99.999999999% durability and multiple storage classes for cost optimization.',
          keyPoints: [
            'S3 stores objects (files) in buckets',
            'Unlimited storage, objects up to 5TB',
            'Storage classes: Standard, IA, Glacier for cost tiers',
            'Versioning protects against accidental deletion',
            'Static website hosting directly from S3',
          ],
        ),
        LessonContent(
          id: 'aws2_3',
          title: 'AWS Lambda & Serverless',
          duration: '12 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=eOBq__h4OJ4',
          summary:
              'AWS Lambda lets you run code without provisioning servers. You upload your function, define a trigger, and Lambda handles execution, scaling, and billing per millisecond of compute time.',
          keyPoints: [
            'No server management required',
            'Supports Python, Node.js, Java, Go, and more',
            'Triggered by events: API calls, S3 uploads, schedules',
            'Pay only for execution time (per 1ms)',
            'Auto-scales from 0 to thousands of concurrent executions',
          ],
        ),
      ]),
      CourseModule(title: 'Module 3: Networking on AWS', lessons: [
        LessonContent(
          id: 'aws3_1',
          title: 'VPC from Scratch',
          duration: '15 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=g2JOHLHh4rI',
          summary:
              'A VPC (Virtual Private Cloud) is your own isolated network within AWS. You define IP ranges, create subnets, configure route tables, and control internet access with internet gateways and NAT gateways.',
          keyPoints: [
            'VPC is a logically isolated network in AWS',
            'Subnets divide VPC into public and private segments',
            'Internet Gateway enables public internet access',
            'NAT Gateway allows private subnets to reach internet',
            'VPC Peering connects two VPCs privately',
          ],
        ),
        LessonContent(
          id: 'aws3_2',
          title: 'Route 53 & DNS',
          duration: '9 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=RGWgfhZByAI',
          summary:
              'Amazon Route 53 is a scalable DNS web service. It translates domain names to IP addresses, routes traffic based on policies, and monitors endpoint health for high availability.',
          keyPoints: [
            'DNS translates domain names to IP addresses',
            'Route 53 supports multiple routing policies',
            'Latency-based routing sends users to nearest region',
            'Health checks monitor endpoint availability',
            'Integrates with other AWS services seamlessly',
          ],
        ),
      ]),
    ],
  ),

  // ── 3. Azure for Beginners ────────────────────────────────────────────────
  CourseInfo(
    id: 'azure-for-beginners',
    title: 'Azure for Beginners',
    category: 'Azure',
    estimatedHours: 6,
    modules: [
      CourseModule(title: 'Module 1: Azure Basics', lessons: [
        LessonContent(
          id: 'az1_1',
          title: 'What is Microsoft Azure?',
          duration: '9 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=NKEFWyqJ5XA',
          summary:
              'Microsoft Azure is a cloud computing platform with 200+ products and services. It enables organizations to build, run, and manage applications across Microsoft-managed data centers worldwide.',
          keyPoints: [
            'Azure has 60+ regions globally',
            'Supports Windows and Linux workloads',
            'Strong integration with Microsoft 365 and Active Directory',
            'Hybrid cloud leader with Azure Arc',
            'Compliance with 90+ regulatory standards',
          ],
        ),
        LessonContent(
          id: 'az1_2',
          title: 'Azure Portal Walkthrough',
          duration: '10 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=NKEFWyqJ5XA',
          summary:
              'The Azure Portal is a unified web console for managing all Azure resources. It provides dashboards, resource groups, cost management, and access to Azure Marketplace for third-party solutions.',
          keyPoints: [
            'Resource Groups organize related Azure resources',
            'Subscriptions are billing and access boundaries',
            'Azure Marketplace for pre-built solutions',
            'Cost Management + Billing for spending visibility',
            'Azure Cloud Shell for browser-based CLI',
          ],
        ),
      ]),
      CourseModule(title: 'Module 2: Azure Compute', lessons: [
        LessonContent(
          id: 'az2_1',
          title: 'Azure Virtual Machines',
          duration: '12 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=inaXkN2UrFE',
          summary:
              'Azure Virtual Machines provide on-demand, scalable computing resources. You can choose from hundreds of VM sizes optimized for different workloads, and pay only for what you use.',
          keyPoints: [
            'VMs support Windows Server and Linux distributions',
            'VM Scale Sets for automatic horizontal scaling',
            'Availability Sets for high availability within a region',
            'Azure Spot VMs for cost savings on interruptible workloads',
            'Managed Disks for simplified storage management',
          ],
        ),
        LessonContent(
          id: 'az2_2',
          title: 'Azure App Service',
          duration: '10 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=4BwyqmRTrx8',
          summary:
              'Azure App Service is a fully managed PaaS for hosting web apps, REST APIs, and mobile backends. It handles infrastructure, patching, and scaling so developers can focus on code.',
          keyPoints: [
            'Supports .NET, Java, Node.js, Python, PHP, Ruby',
            'Built-in auto-scaling and load balancing',
            'Deployment slots for staging and production',
            'Integrated CI/CD with GitHub and Azure DevOps',
            'Custom domains and SSL certificates included',
          ],
        ),
      ]),
      CourseModule(title: 'Module 3: Azure Storage & Databases', lessons: [
        LessonContent(
          id: 'az3_1',
          title: 'Azure Blob Storage',
          duration: '8 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=UJG6viKU_A8',
          summary:
              'Azure Blob Storage is Microsoft\'s object storage solution for the cloud. It is optimized for storing massive amounts of unstructured data like images, videos, backups, and log files.',
          keyPoints: [
            'Three blob types: Block, Append, Page blobs',
            'Access tiers: Hot, Cool, Archive for cost optimization',
            'Geo-redundant storage for disaster recovery',
            'Azure CDN integration for fast global delivery',
            'Lifecycle management policies automate tier transitions',
          ],
        ),
        LessonContent(
          id: 'az3_2',
          title: 'Azure SQL Database',
          duration: '11 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=BgvEOkcR0Wk',
          summary:
              'Azure SQL Database is a fully managed relational database service based on SQL Server. It handles patching, backups, and high availability automatically, letting you focus on application development.',
          keyPoints: [
            'Fully managed SQL Server in the cloud',
            'Built-in high availability with 99.99% SLA',
            'Automatic backups with point-in-time restore',
            'Elastic pools for cost-efficient multi-database management',
            'Advanced threat protection and data encryption',
          ],
        ),
      ]),
    ],
  ),

  // ── 4. Kubernetes Essentials ──────────────────────────────────────────────
  CourseInfo(
    id: 'kubernetes-essentials',
    title: 'Kubernetes Essentials',
    category: 'DevOps',
    estimatedHours: 12,
    modules: [
      CourseModule(title: 'Module 1: Kubernetes Intro', lessons: [
        LessonContent(
          id: 'k8s1_1',
          title: 'Kubernetes in 5 Minutes',
          duration: '5 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=PH-2FfFD2PU',
          summary:
              'Kubernetes (K8s) is an open-source container orchestration platform. It automates deployment, scaling, and management of containerized applications across clusters of machines.',
          keyPoints: [
            'Originally developed by Google, now CNCF project',
            'Automates container deployment and scaling',
            'Self-healing: restarts failed containers automatically',
            'Declarative configuration using YAML manifests',
            'Works with Docker and other container runtimes',
          ],
        ),
        LessonContent(
          id: 'k8s1_2',
          title: 'Pods, Nodes & Clusters',
          duration: '12 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=QJ4fODH6DXI',
          summary:
              'A Kubernetes cluster consists of a control plane and worker nodes. Nodes run Pods, which are the smallest deployable units containing one or more containers that share network and storage.',
          keyPoints: [
            'Cluster = Control Plane + Worker Nodes',
            'Pod = smallest deployable unit (1+ containers)',
            'Node = physical or virtual machine running pods',
            'Control Plane manages cluster state',
            'kubelet agent runs on each node',
          ],
        ),
      ]),
      CourseModule(title: 'Module 2: Deployments & Services', lessons: [
        LessonContent(
          id: 'k8s2_1',
          title: 'Kubernetes Deployments',
          duration: '14 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=mxSmx9T5MpA',
          summary:
              'A Deployment manages a set of identical Pods, ensuring the desired number are always running. It handles rolling updates and rollbacks, making zero-downtime deployments straightforward.',
          keyPoints: [
            'Deployment ensures desired pod count is maintained',
            'Rolling updates replace pods gradually',
            'Rollback to previous version with one command',
            'ReplicaSet maintains pod replicas under the hood',
            'Deployment YAML defines image, replicas, and strategy',
          ],
        ),
        LessonContent(
          id: 'k8s2_2',
          title: 'Services & Networking',
          duration: '11 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=5lzUpDtmWgM',
          summary:
              'Kubernetes Services provide stable network endpoints for Pods. Since Pod IPs change, Services give a consistent DNS name and IP. Types include ClusterIP, NodePort, and LoadBalancer.',
          keyPoints: [
            'ClusterIP: Internal cluster communication only',
            'NodePort: Exposes service on each node\'s IP',
            'LoadBalancer: Provisions cloud load balancer',
            'Ingress: HTTP routing rules for external access',
            'DNS-based service discovery within cluster',
          ],
        ),
        LessonContent(
          id: 'k8s2_3',
          title: 'ConfigMaps & Secrets',
          duration: '9 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=FAnQTgr04mU',
          summary:
              'ConfigMaps store non-sensitive configuration data as key-value pairs. Secrets store sensitive data like passwords and API keys in base64-encoded form. Both decouple config from container images.',
          keyPoints: [
            'ConfigMap: Non-sensitive config (env vars, config files)',
            'Secret: Sensitive data (passwords, tokens, keys)',
            'Mount as environment variables or volume files',
            'Secrets are base64-encoded (not encrypted by default)',
            'Use external secret managers for production security',
          ],
        ),
      ]),
      CourseModule(title: 'Module 3: Advanced Kubernetes', lessons: [
        LessonContent(
          id: 'k8s3_1',
          title: 'Helm Charts Explained',
          duration: '13 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=-ykwb1d0DXU',
          summary:
              'Helm is the package manager for Kubernetes. Charts are packages of pre-configured Kubernetes resources. Helm simplifies deploying complex applications and managing their lifecycle.',
          keyPoints: [
            'Helm = package manager for Kubernetes',
            'Chart = collection of Kubernetes YAML templates',
            'Values.yaml customizes chart configuration',
            'Helm Hub has thousands of community charts',
            'Releases track deployed chart instances',
          ],
        ),
        LessonContent(
          id: 'k8s3_2',
          title: 'Kubernetes Monitoring',
          duration: '10 min',
          youtubeUrl: 'https://www.youtube.com/watch?v=QoDqxm7ybLc',
          summary:
              'Monitoring Kubernetes involves tracking cluster health, resource usage, and application performance. Prometheus collects metrics, Grafana visualizes them, and alerting rules notify on issues.',
          keyPoints: [
            'Prometheus scrapes metrics from pods and nodes',
            'Grafana creates dashboards from Prometheus data',
            'kubectl top shows real-time resource usage',
            'Liveness probes restart unhealthy containers',
            'Readiness probes control traffic routing to pods',
          ],
        ),
      ]),
    ],
  ),
];

// Helper: find course by id
CourseInfo? findCourse(String id) {
  for (final c in allCourses) {
    if (c.id == id) return c;
  }
  return null;
}
