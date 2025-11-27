#!/bin/bash
echo "🔍 Debugging Argo CD Accessibility..."
echo "======================================"

echo ""
echo "1. Argo CD Pods Status:"
kubectl get pods -n argocd -o wide

echo ""
echo "2. Argo CD Services:"
kubectl get services -n argocd

echo ""
echo "3. Ingress Status:"
kubectl get ingress -n argocd -o wide

echo ""
echo "4. Traefik Status:"
kubectl get pods -n kube-system -l app=traefik

echo ""
echo "5. Recent Events:"
kubectl get events -n argocd --sort-by=.lastTimestamp | tail -10

echo ""
echo "6. DNS Resolution:"
nslookup argocd.autoscaleops.com 2>/dev/null || echo "nslookup not available"

echo ""
echo "7. Server External IP:"
curl -4 icanhazip.com 2>/dev/null || hostname -I | awk '{print $1}'

echo ""
echo "8. Testing Internal Access (will take a few seconds):"
timeout 10s kubectl port-forward svc/argocd-server -n argocd 18443:443 2>/dev/null &
sleep 3
curl -k -s -o /dev/null -w "HTTP Status: %{http_code}\n" https://localhost:18443/healthz 2>/dev/null || echo "Internal access failed"
pkill -f "port-forward"

echo ""
echo "9. Pod Logs (last few lines):"
for pod in $(kubectl get pods -n argocd -o name | head -3); do
    echo "--- $pod ---"
    kubectl logs -n argocd $pod --tail=5 2>/dev/null | tail -3
done