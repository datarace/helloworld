node {
    def app
	def deployment = "bluegreen" 

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
          sh "kubectl set image datarace/helloworld helloworld=datarace/helloworld:${env.BUILD_NUMBER} --kubeconfig=/kubernetes/config/admin.conf"
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
          sh "kubectl set image deployment/helloworld helloworld=datarace/helloworld:${env.BUILD_NUMBER} --kubeconfig=/kubernetes/config/admin.conf"
	      sleep 30    
          sh "kubectl delete -f helloworld-canary-deployment.yaml --kubeconfig=/kubernetes/config/admin.conf" 
          sh "kubectl apply -f helloworld-production-service.yaml --kubeconfig=/kubernetes/config/admin.conf" 
        }

     }
	 
     /* RUN A BLUE/GREEN */
     if (deployment == "bluegreen") {       
       stage('Deploy GREEN Release') { 	   
     	  sh "sed -ie 's/THIS_STRING_IS_REPLACED_DURING_BUILD/${env.BUILD_NUMBER}/g' helloworld-bluegreen-deployment.yaml"
	  sh "sed -ie 's/REPLACED_BY_VERSION_DURING_BUILD/${env.BUILD_NUMBER}/g' helloworld-bluegreen-deployment.yaml"
          sh "kubectl apply -f helloworld-bluegreen-deployment.yaml --kubeconfig=/kubernetes/config/admin.conf"
	      sleep 60
        }
               
       stage('Switchover to GREEN') { 	
	  /* 
	   * Save existing service in case we need to back out manually later
	   */
	  sh "kubectl get service helloworld -o yaml --kubeconfig=/kubernetes/config/admin.conf > service_backout.yaml"
	  /*
	   * Hook jenkins build number into selector so we hook into the correct build
	   */
	  sh "sed -ie 's/REPLACED_BY_VERSION_DURING_BUILD/${env.BUILD_NUMBER}/g' helloworld-bluegreen-service.yaml"  
          sh "kubectl apply -f helloworld-bluegreen-service.yaml --kubeconfig=/kubernetes/config/admin.conf"
        }
		
       /*stage('Run Testing') { 
           COLOUR = sh (
                   script: 'curl http://kube001:30000|grep -E 'BLUE|GREEN'|wc -l',
                   returnStdout: true
            ).trim()
          echo "Counted this number of BLUE or GREEN ${COLOUR}"
          sleep 30
        }

       stage('SwitchBack to BLUE') { 	   
          sh "kubectl apply -f helloworld-production-service.yaml --kubeconfig=/kubernetes/config/admin.conf"  
          sh "kubectl delete -f helloworld-bluegreen-deployment.yaml --kubeconfig=/kubernetes/config/admin.conf" 
        }*/

     } 
	    
	    
		
    }
	 
    
	
}
  
