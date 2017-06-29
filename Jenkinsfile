node {
    def app
	def deployment = "rolling" 

    stage('Clone GIT') {
        /* Let's make sure we have the repository cloned to our workspace */

        checkout scm
    }

    stage('Build Docker Image') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */

        app = docker.build("datarace/helloworld")
    }

    stage('Run Unit Tests') {
        /* Ideally, we would run a test framework against our image.
         * For this example, we're using a Volkswagen-type approach ;-) */

        app.inside {
            sh 'echo "Tests passed"'
        }
    }

    stage('Push Image to Source Control') {
        /* Finally, we'll push the image with two tags:
         * First, the incremental build number from Jenkins
         * Second, the 'latest' tag.
         * Pushing multiple tags is cheap, as all the layers are reused. */
        docker.withRegistry('https://10.0.0.13:18443', 'nexus-admin') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }
    
	
    stage('Deploy to K8S') {
    
    sleep 5
	
     /* RUN A ROLLING DEPLOYMENT */
     if (deployment == "dummy") {                                          
       echo "dummy"          	
     }
		
        
     /* RUN A ROLLING DEPLOYMENT */
     if (deployment == "rolling") {                                          
               
        stage('Deploy Rolling Upgrade') { 	   
          sh "kubectl set image https://10.0.0.13:18443/helloworld helloworld=datarace/helloworld:${env.BUILD_NUMBER} --kubeconfig=/kubernetes/config/admin.conf"
          sleep 120
		
        }
		
     }
 
     /* RUN A CANARY DEPLOYMENT */
     if (deployment == "canary") {       
	     
       stage('Deploy Canary Release') { 	   
          sh "kubectl apply -f helloworld-canary-deployment.yaml --kubeconfig=/kubernetes/config/admin.conf"
          sh "kubectl apply -f helloworld-canary-service.yaml --kubeconfig=/kubernetes/config/admin.conf"  
	      sleep 60
        }
               
       stage('Run Canary Testing') { 	   
          sleep 60
        }

       stage('Promote to Production') { 	   
          sh "kubectl set image deployment/helloworld helloworld=jonathanfane/helloworld:${env.BUILD_NUMBER} --kubeconfig=/kubernetes/config/admin.conf"
	      sleep 30    
          sh "kubectl delete -f helloworld-canary-deployment.yaml --kubeconfig=/kubernetes/config/admin.conf" 
          sh "kubectl apply -f helloworld-production-service.yaml --kubeconfig=/kubernetes/config/admin.conf" 
        }

     }
	 
     /* RUN A BLUE/GREEN */
     if (deployment == "bluegreen") {       
	     
       stage('Deploy GREEN Release') { 	   
          sh "kubectl apply -f helloworld-bluegreen-deployment.yaml --kubeconfig=/kubernetes/config/admin.conf"
	      sleep 60
        }
               
       stage('Switchover to GREEN') { 	   
          sh "kubectl apply -f helloworld-bluegreen-service.yaml --kubeconfig=/kubernetes/config/admin.conf"
        }
		
       stage('Run Testing') { 	   
          sleep 30
        }

       stage('SwitchBack to BLUE') { 	   
          sh "kubectl apply -f helloworld-production-service.yaml --kubeconfig=/kubernetes/config/admin.conf"  
          sh "kubectl delete -f helloworld-bluegreen-deployment.yaml --kubeconfig=/kubernetes/config/admin.conf" 
        }

     } 
	    
	    
		
    }
	 
    
	
}
  
