resource "aws_alb_target_group" "search" {
  name     = "vespa-search-cluster"
  port     = 8080
  protocol = "TCP"
  vpc_id   = data.aws_vpc.this.id
}

resource "aws_alb_target_group_attachment" "search" {
  count            = local.search_count
  target_group_arn = aws_alb_target_group.search.arn
  target_id        = aws_instance.search[count.index].id
  port             = 8080
}

resource "aws_alb_target_group" "config" {
  name     = "vespa-config-cluster"
  port     = 19071
  protocol = "TCP"
  vpc_id   = data.aws_vpc.this.id
}

resource "aws_alb_target_group_attachment" "config" {
  count            = local.configserver_count
  target_group_arn = aws_alb_target_group.config.arn
  target_id        = aws_instance.configserver[count.index].id
  port             = 8080
}

resource "aws_alb" "this" {
  name                             = "vespa"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = [data.aws_subnet.this.id]
  enable_cross_zone_load_balancing = false
}

resource "aws_alb_listener" "search" {
  load_balancer_arn = aws_alb.this.arn
  port              = 8080
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.search.arn
  }
}

resource "aws_alb_listener" "config" {
  load_balancer_arn = aws_alb.this.arn
  port              = 19071
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.config.arn
  }
}

output "alb_dns" {
  value = aws_alb.this.dns_name
}
